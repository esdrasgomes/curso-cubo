PROMPT CREATE OR REPLACE FUNCTION f_avadebug08
CREATE OR REPLACE FUNCTION f_avadebug08 (nCdRegFat       IN dbamv.reg_fat.cd_reg_fat%type /*NUMBER pda 254997*/,
                                  nCdRegAmb       IN dbamv.reg_amb.cd_reg_amb%type /*NUMBER pda 254997*/,
                                  nCdAtend        IN NUMBER,
                                  nCdMultiEmpresa IN NUMBER,
                                  nCdProFat       IN NUMBER default NULL,
                                  nCdPrestador    IN NUMBER default NULL )
RETURN Number IS
  CURSOR c_Prestador IS
    select distinct cd_prestador           cd_prestador,
                    cd_prestador_repasse   cd_prestador_repasse
    from   dbamv.v_repasse_prestador2 v_repasse
    where ( (v_repasse.cd_reg_fat = nCdRegFat and nvl(nCdRegFat,0) <> 0) OR
    (v_repasse.cd_atendimento = nCdAtend and v_repasse.cd_reg_amb = nCdRegAmb and nvl(nCdRegAmb,0) <> 0) )
    and    cd_prestador           = nvl(nCdPrestador,cd_prestador)
    and    tp_pagamento           = 'P'
    and    v_repasse.cd_multi_empresa =  nCdMultiEmpresa ;
  CURSOR c_Repasse (v_cd_prestador in Number) IS
    select cd_reg_repasse,
           cd_convenio,
           cd_ori_ate,
           cd_gru_pro,
           cd_pro_fat,
           cd_ati_med,
           sn_pertence_pacote,
           cd_tip_acom,
           cd_setor,
           filme,
           nvl(vl_total_conta, 0) vl_total,
           qt_lancamento
    from   dbamv.v_repasse_prestador2 v_repasse
    where ( (v_repasse.cd_reg_fat = nCdRegFat and nvl(nCdRegFat,0) <> 0) OR
    (v_repasse.cd_atendimento = nCdAtend and v_repasse.cd_reg_amb = nCdRegAmb and nvl(nCdRegAmb,0) <> 0) )
    and    cd_pro_fat             = nvl(nCdProFat,cd_pro_fat)
    and    v_repasse.tp_pagamento        = 'P'
    and    v_repasse.cd_multi_empresa    =  nCdMultiEmpresa
    and    v_repasse.cd_prestador        =  v_cd_prestador;
  CURSOR c_regra (v_cd_reg_repasse in Number, v_cd_convenio in Number, v_cd_ori_ate in Number,
                  v_cd_gru_pro in Number, v_cd_pro_fat in varchar2, v_cd_ati_med in varchar2,
                  v_sn_pertence_pacote in varchar2, v_cd_tip_acom in number, v_cd_setor in Number)
   IS
    select vl_percent_pago, vl_procedimento,vl_percent_desc, vl_desconto, sn_inside_no_filme
    from dbamv.itreg_repasse itreg_repasse
    where itreg_repasse.cd_reg_repasse = v_cd_reg_repasse
     and ( itreg_repasse.cd_convenio = v_cd_convenio or itreg_repasse.cd_convenio is null )
     and ( itreg_repasse.cd_ori_ate  = v_cd_ori_ate  or itreg_repasse.cd_ori_ate is null )
     and ( itreg_repasse.cd_gru_pro  = v_cd_gru_pro  or itreg_repasse.cd_gru_pro is null )
     and ( itreg_repasse.cd_pro_fat  = v_cd_pro_fat  or itreg_repasse.cd_pro_fat is null )
     and ( itreg_repasse.cd_ati_med  = v_cd_ati_med  or itreg_repasse.cd_ati_med is null )
     and ( itreg_repasse.sn_pertence_pacote = v_sn_pertence_pacote or itreg_repasse.sn_pertence_pacote = 'N')
     and ( itreg_repasse.cd_tip_acom = v_cd_tip_acom or itreg_repasse.cd_tip_acom is null )
     and ( itreg_repasse.cd_setor    = v_cd_setor    or itreg_repasse.cd_setor is null)
   order by sn_pertence_pacote desc, cd_pro_Fat, cd_ati_med, cd_tip_acom, cd_gru_pro, cd_ori_ate, cd_convenio, cd_setor ;
  CURSOR C_ATI_MED (v_cd_ati_med in varchar2) IS
    select vl_percentual_pago,
           tp_funcao
    from dbamv.ati_med
    where cd_ati_med = v_cd_ati_med;
  nVl_Perc_Ati_Med  dbamv.ATI_MED.VL_PERCENTUAL_PAGO%TYPE;
  cTp_funcao        dbamv.ATI_MED.TP_FUNCAO%TYPE;
  nCdRepasse        number(8);
  nVlTotal          number(12,2);
  nVlRepasse        number(12,2);
  nVl_a_Repassar    number(12,2);
  nVl_Faturado      number(12,2);
  nCdItRepasse      number(8);
  nCont             number(8);
  nContRegra        number(8);
Begin
    nCont := 0;
    nVlTotal       := 0;
    nVlRepasse     := 0;
    nVl_a_Repassar := 0;
    nVl_Faturado   := 0;
 For r in c_prestador LOOP
    For r1 in c_repasse (r.cd_prestador) LOOP
      nContRegra := 0;
      For r2 in c_regra ( r1.cd_reg_repasse    , r1.cd_convenio, r1.cd_ori_ate,
                          r1.cd_gru_pro        , r1.cd_pro_fat , r1.cd_ati_med,
                          r1.sn_pertence_pacote, r1.cd_tip_acom, r1.cd_setor) LOOP
        nContRegra := nContRegra + 1;
        IF r1.filme <> 0  and r2.sn_inside_no_filme = 'N' THEN
          nVlTotal := r1.vl_total - r1.filme;
          IF r2.vl_percent_pago is not null THEN
            nVlRepasse := round(((nVlTotal * r2.vl_percent_pago) / 100 ) - nvl(r2.vl_desconto, 0),2);
          ELSIF r2.vl_procedimento is not null THEN
            nVlRepasse := round((r2.vl_procedimento *  r1.qt_lancamento) -
                              (((r2.vl_procedimento *  r1.qt_lancamento) * nvl(r2.vl_percent_desc,0))/100 ),2);
            IF r1.cd_ati_med is not null THEN
              OPEN C_ATI_MED (r1.cd_ati_med);
              FETCH C_ATI_MED
              INTO nVl_Perc_Ati_Med,cTp_funcao;
              CLOSE C_ATI_MED;
              nVlRepasse := round(((nVlRepasse * nvl(nVl_Perc_Ati_Med,0) ) / 100),2);
            END IF;
          ELSE
            nVlRepasse := nVlTotal;
          END IF;
        ELSE
          IF r2.vl_percent_pago is not null THEN
            nVlRepasse := round(((r1.vl_total * r2.vl_percent_pago) / 100 ) - nvl(r2.vl_desconto, 0),2);
          ELSIF r2.vl_procedimento is not null THEN
            nVlRepasse := round((r2.vl_procedimento *  r1.qt_lancamento) -
                         (((r2.vl_procedimento *  r1.qt_lancamento) * nvl(r2.vl_percent_desc,0))/100 ),2);
            IF r1.cd_ati_med is not null THEN
              OPEN C_ATI_MED (r1.cd_ati_med);
              FETCH C_ATI_MED
              INTO nVl_Perc_Ati_Med,cTp_funcao;
              CLOSE C_ATI_MED;
              nVlRepasse := round(((nVlRepasse * nvl(nVl_Perc_Ati_Med,0) ) / 100),2);
            END IF;
          ELSE
            nVlRepasse := r1.vl_total;
          END IF;
        END IF;
        IF r1.filme <> 0 THEN
          IF r2.sn_inside_no_filme = 'N' THEN
            nVlRepasse := nVlRepasse + r1.filme;
          END IF;
        END IF;
        nVl_a_Repassar := nvl(nVl_a_Repassar, 0) + nvl(nVlRepasse, 0);
        nVl_Faturado   := nvl(nVl_Faturado  , 0) + nvl(r1.Vl_Total  , 0);
        nCont := nCont + 1;
        Exit;
      End Loop;
      If nvl(nContRegra,0) =  0 Then
        nVl_a_Repassar := nvl(nVl_a_Repassar, 0) + nvl(r1.vl_total  , 0);
        nVl_Faturado   := nvl(nVl_Faturado  , 0) + nvl(r1.vl_total  , 0);
      End If;
    End Loop;
  End Loop;
    Return nVl_a_Repassar;
END;
/

