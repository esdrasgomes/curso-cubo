PROMPT CREATE OR REPLACE TRIGGER trg_ava08
CREATE OR REPLACE TRIGGER trg_ava08

 AFTER

 INSERT OR UPDATE

 ON reccon_rec

 REFERENCING OLD AS OLD NEW AS NEW

 FOR EACH ROW



declare

   vll_recebido                  dbamv.reccon_rec.vl_recebido%type;

   vll_recebido_old              dbamv.reccon_rec.vl_recebido%type;

   vtp_quitacao                  dbamv.itcon_rec.tp_quitacao%type;

   vvl_duplicata                 dbamv.itcon_rec.vl_duplicata%type;

   vvl_glosa                     dbamv.itcon_rec.vl_glosa%type;

   vvl_soma_recebido             dbamv.itcon_rec.vl_soma_recebido%type;

   vvl_soma_recebido_new         dbamv.itcon_rec.vl_soma_recebido%type;

   vcd_con_rec                   dbamv.itcon_rec.cd_con_rec_agrup%type;

   vcd_con_rec_agrup             dbamv.itcon_rec.cd_con_rec_agrup%type;

   vcd_mov_concor                dbamv.mov_concor.cd_mov_concor%type;

   vcd_multi_empresa             dbamv.con_rec.cd_multi_empresa%type;

   vcd_doc_caixa                 dbamv.doc_caixa.cd_doc_caixa%type;

   vcd_mov_caixa                 dbamv.doc_caixa.cd_doc_caixa%type;

   vnm_cliente                   dbamv.con_rec.nm_cliente%type;

   vtp_con_rec                   dbamv.con_rec.tp_con_rec%type;

   vcd_atendimento               dbamv.con_rec.cd_atendimento%type;

   vcd_remessa                   dbamv.con_rec.cd_remessa%type;

   vcd_reg_fat                   dbamv.con_rec.cd_reg_fat%type;

   vcd_reg_amb                   dbamv.con_rec.cd_reg_amb%type;

   vdt_prevista                  dbamv.itcon_rec.dt_prevista_recebimento%type;

   vVlGlosa                      dbamv.itcon_rec.vl_glosa%type; -- PDA 142791 Implementac?o Contabilizac?o de glosa.

   nCdContratoAdiant             dbamv.con_rec.cd_contrato_adiant%TYPE;

   vExiste                 varchar2(1);

   vVlSaldoRecebido        dbamv.contrato_adiantamento.vl_saldo_recebido%type;

   vStContratoAdiant       dbamv.contrato_adiantamento.st_contrato_adiant%type;

-- Cursor com Dados da Parcela

-- ---------------------------------------------

   cursor cur_parcelas(pcd_itcon_rec   in    number )   is

      select vl_duplicata, vl_soma_recebido, vl_glosa, cd_con_rec_agrup,

             cd_con_rec, dt_prevista_recebimento

        from dbamv.itcon_rec

       where cd_itcon_rec = pcd_itcon_rec;

-- Cursor com Dados da Conta

-- ---------------------------------------------

   cursor cur_conta(pcd_con_rec  in number )  is

      select cd_multi_empresa, substr( nm_cliente, 1, 35 ) nm_cliente,

             tp_con_rec, cd_atendimento, cd_remessa, cd_reg_fat, cd_reg_amb

        from dbamv.con_rec

       where cd_con_rec = pcd_con_rec;

-- Cursor com Documento de Cauc?o

-- ---------------------------------------------

   cursor cur_doc_caucao  is

      select cd_doc_caixa

        from dbamv.doc_caixa

       where cd_caucao = :new.cd_caucao;

-- Cursor com Documento de Cauc?o

-- ---------------------------------------------

   cursor cur_mov_caixa  is

      select cd_mov_caixa

        from dbamv.mov_caixa

       where cd_caucao = :new.cd_caucao;



       --Alimentar a rat_reccon_rec

	cursor cRateio  Is

	    SELECT CR.CD_CON_REC ,

	            RAT.CD_ITEM_RES ,

	            RAT.CD_SETOR ,

	            ROUND(RAT.VL_RATEIO/CR.VL_PREVISTO * :NEW.VL_RECEBIDO, 2)  VL_BASE_REC,

	            RAT.CD_REDUZIDO

	    FROM DBAMV.CON_REC CR ,

	          DBAMV.RAT_CONREC RAT,

	          DBAMV.ITCON_REC IT

	    WHERE CR.CD_CON_REC  = IT.CD_CON_REC

	    AND CR.CD_CON_REC    = RAT.CD_CON_REC

	    AND IT.CD_ITCON_REC  = :NEW.CD_ITCON_REC



	    AND CR.SN_AGRUPAMENTO <> 'S'



	    UNION ALL



	    SELECT CR.CD_CON_REC ,

	            RAT.CD_ITEM_RES ,

	            RAT.CD_SETOR ,

	            ROUND(RAT.VL_RATEIO/(SELECT Nvl(Sum(Nvl(RAT.VL_RATEIO,0)),0)

	                                   FROM DBAMV.CON_REC CR

	                                        , DBAMV.RAT_CONREC RAT

	                                        , DBAMV.ITCON_REC IT

	                                        ,(SELECT cd_con_rec_agrup, cd_con_rec FROM dbamv.itcon_rec GROUP BY cd_con_rec_agrup, cd_con_rec) IT_AGRUP

	                                  WHERE IT.CD_ITCON_REC = :NEW.CD_ITCON_REC

	                                  AND CR.CD_CON_REC = IT.CD_CON_REC

	                                  AND IT.CD_CON_REC = IT_AGRUP.CD_CON_REC_AGRUP

	                                  AND IT_AGRUP.CD_CON_REC = RAT.CD_CON_REC

	                                  AND CR.SN_AGRUPAMENTO <> 'N') * :NEW.VL_RECEBIDO, 2)  VL_BASE_REC,

	            RAT.CD_REDUZIDO

	    FROM DBAMV.CON_REC CR

	          , DBAMV.RAT_CONREC RAT

	          , DBAMV.ITCON_REC IT

	          ,(SELECT cd_con_rec_agrup, cd_con_rec FROM dbamv.itcon_rec GROUP BY cd_con_rec_agrup, cd_con_rec) IT_AGRUP

	          -- , DBAMV.ITCON_REC IT_AGRUP



	    WHERE IT.CD_ITCON_REC = :NEW.CD_ITCON_REC

	    AND CR.CD_CON_REC = IT.CD_CON_REC

	    AND IT.CD_CON_REC = IT_AGRUP.CD_CON_REC_AGRUP

	    AND IT_AGRUP.CD_CON_REC = RAT.CD_CON_REC



	    AND CR.SN_AGRUPAMENTO = 'N';

  ---

   Cursor cDadosContrato is

       Select ca.cd_contrato_adiant,

              c.cd_con_rec,

              ca.VL_SALDO_RECEBIDO

          from dbamv.contrato_adiantamento ca,

               dbamv.con_rec c,

               dbamv.itcon_rec i

         where ca.cd_contrato_adiant = c.cd_contrato_adiant

           and c.cd_con_rec = i.cd_con_rec

           and i.cd_itcon_rec = nvl( :new.cd_itcon_rec, :old.cd_itcon_rec );

    -- Verifica se todas as parcelas do contrato est?o quitadas

    Cursor cVerificaParcelas(pCdConRec in number, pTpQuitacao in varchar2) is

      Select 'X'

        from dbamv.itcon_rec i

       where i.tp_quitacao <> pTpQuitacao

         and i.cd_con_rec = pCdConRec

         and i.cd_itcon_rec <>  nvl( :new.cd_itcon_rec, :old.cd_itcon_rec );

  cursor cContaCancelada(pCdItconRec dbamv.itcon_rec.cd_itcon_rec%type) is

    select 'X'

      from dbamv.con_rec c

         , dbamv.itcon_rec it

     where c.cd_con_rec = it.cd_con_rec

       and it.cd_itcon_rec = pCdItconRec

       and c.dt_cancelamento is not null;

	vContaCancelada varchar2(1);

	vTotal_Rateio_Rec     dbamv.reccon_rec.vl_recebido%type;

	vVl_Diferenca_Rec 	  dbamv.reccon_rec.vl_recebido%type;

begin

    if updating('cd_exp_contab_estorno_baixa') or updating('cd_exp_contabilidade') then

        return;

    end if;

    -- N?o permitir a cancelamento de um estorno de baixa contabil quando a mesma estiver importada para contabilidade.

    if  updating('Vl_estorno') and updating('Nm_usuario') and updating('Cd_Motivo_Canc') and

        updating('cd_processo_sec') and updating('ds_estorno') and :old.cd_exp_contab_estorno_baixa is not null then

        raise_application_error( -20005,  pkg_rmi_traducao.extrair_proc_msg('MSG_1', 'TRG_RECCON_REC_AFTER', 'Erro: N?o e permitido realizar o cancelamento do estorno da baixa contabil, a mesma encontra-se na contabilidade!') );

    end if;



 -- Dados da Parcela

-- ---------------------------------------------

   open cur_parcelas( nvl( :new.cd_itcon_rec, :old.cd_itcon_rec ));

   fetch cur_parcelas into vvl_duplicata,

                           vvl_soma_recebido,

                           vvl_glosa,

                           vcd_con_rec_agrup,

                           vcd_con_rec,

                           vdt_prevista;

   close cur_parcelas;

   --

   open cur_conta( vcd_con_rec );

   fetch cur_conta into vcd_multi_empresa,

                        vnm_cliente,

                        vtp_con_rec,

                        vcd_atendimento,

                        vcd_remessa,

                        vcd_reg_fat,

                        vcd_reg_amb;

   close cur_conta;

   Open cDadosContrato;

   Fetch cDadosContrato into nCdContratoAdiant, vcd_con_rec, vVlSaldoRecebido;

   Close cDadosContrato;

   if inserting then

-- INSERT

-- ---------------------------------------------

      vll_recebido :=

            nvl( :new.vl_recebido, 0 )

          + nvl( :new.vl_desconto, 0 )

          - nvl( :new.vl_acrescimo, 0 )

          + nvl( :new.vl_imposto_retido, 0 );




      vll_recebido_old := 0;

      --

      if :new.cd_caucao is not null and :new.tp_recebimento in( 1, 2, 8, 9 )  then

         open cur_mov_caixa;

         fetch cur_mov_caixa into vcd_mov_caixa;

         close cur_mov_caixa;

         if :new.cd_mov_caixa is null

         then

            update reccon_rec

               set cd_mov_caixa = vcd_mov_caixa

             where cd_reccon_rec = :new.cd_reccon_rec;

         end if;

         open cur_doc_caucao;

         fetch cur_doc_caucao into vcd_doc_caixa;

         close cur_doc_caucao;

         if vcd_doc_caixa is not null

         then

            if :new.cd_doc_caixa is null

            then

               update reccon_rec

                  set cd_doc_caixa = vcd_doc_caixa

                where cd_reccon_rec = :new.cd_reccon_rec;

            end if;

         end if;

      end if;

      -- Caso o recebimento seja de recurso, sera inserido o registro na tabela mov_glosas.

      if :new.cd_remessa_glosa is not null and :new.tp_lancamento is null then

        begin

         insert into dbamv.mov_glosas

                    (cd_mov_glosas

                    ,cd_itcon_rec

                    ,cd_reccon_rec

                    ,cd_processo

                    ,ds_mov_glosa

                    ,dt_movimentacao

                    ,vl_movimentacao

                    ,cd_remessa_glosa

                    ,cd_multi_empresa)

              values

                    (dbamv.seq_mov_glosas.nextval

                    ,:new.cd_itcon_rec

                    ,:new.cd_reccon_rec

                    ,:new.cd_processo

                    ,:new.ds_reccon_rec

                    ,:new.dt_recebimento

                    ,vll_recebido

                    ,:new.cd_remessa_glosa

                    ,:new.cd_multi_empresa );

        exception

          when others then

             raise_application_error( -20004,

                          pkg_rmi_traducao.extrair_proc_msg('MSG_2', 'TRG_RECCON_REC_AFTER', 'Erro ao inserir dados na tabela mov_glosas: trg_reccon_rec_after.') );

        end;

      end if;

      For n In cRateio Loop  /* Rateio dos recebimentos*/

            Insert Into Dbamv.Rat_Reccon_Rec

            Values( Dbamv.Seq_Rat_Reccon_Rec.Nextval

                    , :new.cd_reccon_rec

                    , n.cd_setor

                    , n.cd_item_res

                    , n.Vl_Base_Rec

                    , :new.cd_multi_empresa

                    ,n.cd_reduzido);

      End Loop; /* loop cRateio_Rec*/

      /*Verificac?o final se os valores entre reccon_rec e rat_reccon_rec est?o fechando*/

      Select Sum(vl_rat_reccon_rec)

      Into vTotal_Rateio_Rec

      From Dbamv.Rat_Reccon_Rec

      Where cd_reccon_rec = :new.cd_reccon_rec;

      If vTotal_Rateio_Rec <> :new.vl_recebido Then

             vVl_Diferenca_Rec := vTotal_Rateio_Rec - :new.vl_recebido;

             Update Dbamv.Rat_Reccon_Rec

             Set vl_rat_reccon_rec = vl_rat_reccon_rec - vVl_Diferenca_Rec

             Where (vl_rat_reccon_rec - vVl_Diferenca_Rec) >= 0

        	 And cd_reccon_rec =:new.cd_reccon_rec

             And rownum = 1;

      End If;

   elsif updating  then

-- UPDATE

-- ---------------------------------------------

      vll_recebido :=

            nvl( :new.vl_recebido, 0 )

          + nvl( :new.vl_desconto, 0 )

          - nvl( :new.vl_acrescimo, 0 )

          + nvl( :new.vl_imposto_retido, 0 );

      vll_recebido_old :=

            nvl( :old.vl_recebido, 0 )

          + nvl( :old.vl_desconto, 0 )

          - nvl( :old.vl_acrescimo, 0 )

          + nvl( :new.vl_imposto_retido, 0 );

      if :new.cd_caixa is not null and :new.tp_recebimento in( 1, 2, 8, 9 )    then

         update dbamv.doc_caixa

            set ds_observacao = :new.ds_observacao,

                cd_resposavel = :new.cd_resposavel

          where cd_doc_caixa = :new.cd_doc_caixa;

      end if;

   end if;

  ----

   if :new.dt_estorno is not null and inserting  then

-- Insert de Pagamento Estornado

-- (Carga Inicial - N?o altera o saldo)

-- ---------------------------------------------

      vvl_soma_recebido_new := nvl( vvl_soma_recebido, 0 );

   elsif :new.dt_estorno is null and :old.dt_estorno is null then

-- Recebimento comum

-- ---------------------------------------------

      vvl_soma_recebido_new :=  nvl( vvl_soma_recebido, 0 ) + vll_recebido - vll_recebido_old;

      If nCdContratoAdiant is not null Then

        vVlSaldoRecebido := nvl(vVlSaldoRecebido, 0) + vll_recebido - vll_recebido_old;

      End If;

   elsif :new.dt_estorno is not null and :old.dt_estorno is null  then

-- Estorno de Recebimento

-- ---------------------------------------------

      vvl_soma_recebido_new := nvl( vvl_soma_recebido, 0 ) - vll_recebido;

      If nCdContratoAdiant is not null Then

        vVlSaldoRecebido := nvl(vVlSaldoRecebido, 0) - vll_recebido ;

      End If;

   elsif :new.dt_estorno is null and :old.dt_estorno is not null  then

-- Cancelamento do Estorno

-- ---------------------------------------------

      vvl_soma_recebido_new := nvl( vvl_soma_recebido, 0 ) + vll_recebido;

      If nCdContratoAdiant is not null Then

        vVlSaldoRecebido := nvl(vVlSaldoRecebido, 0) + vll_recebido ;

      End If;

   else

-- Erro : Estorno n?o pode ser alterado

-- ---------------------------------------------

      raise_application_error( -20001,

                               --MULTI-IDIOMA: Utilizac?o do pkg_rmi_traducao.extrair_msg para mensagens (MSG_3)

                               pkg_rmi_traducao.extrair_proc_msg('MSG_3', 'TRG_RECCON_REC_AFTER', 'Valores do Estorno nao podem ser alterados.') );

   end if;

   if vvl_soma_recebido_new = vvl_duplicata and nvl( vvl_glosa, 0 ) = 0   then

-- Quitado

-- ---------------------------------------------

      vtp_quitacao := 'Q';

      If nCdContratoAdiant is not null Then

        Open cVerificaParcelas(vcd_con_rec , vtp_quitacao);

        Fetch cVerificaParcelas into vExiste;

        if cVerificaParcelas%NotFound then

           vStContratoAdiant := 'Q';

        else

           vStContratoAdiant := 'P';

        end if;

        close cVerificaParcelas;

      End If;

   elsif vvl_soma_recebido_new = vvl_duplicata and nvl( vvl_glosa, 0 ) > 0   then

-- Quitado com Glosa

-- ---------------------------------------------

      vtp_quitacao := 'G';

   elsif vvl_soma_recebido_new < vvl_duplicata and vvl_soma_recebido_new > 0   then

-- Parcialmente Quitado

-- ---------------------------------------------

      vtp_quitacao := 'P';

      If nCdContratoAdiant is not null Then

        vStContratoAdiant := 'P';

      End If;

   elsif vvl_soma_recebido_new = 0   then

-- Comprometido

-- ---------------------------------------------

      vtp_quitacao := 'C';

      If nCdContratoAdiant is not null Then

        Open cVerificaParcelas(vcd_con_rec , vtp_quitacao);

        Fetch cVerificaParcelas into vExiste;

        If cVerificaParcelas%NotFound Then

           vStContratoAdiant := 'C';

        End if;

        Close cVerificaParcelas;

      End If;

   elsif vvl_soma_recebido_new > vvl_duplicata   then

-- Erro : Valor > Duplicata

-- ---------------------------------------------

      raise_application_error( -20002, pkg_rmi_traducao.extrair_proc_msg('MSG_4', 'TRG_RECCON_REC_AFTER'

              , 'Valor Recebido maior(%s) que Saldo a Receber(%s). Conta a receber: %s - Item de recebimento: %s'

              , arg_list(vvl_soma_recebido_new, vvl_duplicata, vcd_con_rec, nvl(:new.cd_itcon_rec,:old.cd_itcon_rec))) );

   else

-- Erro : Valor < 0

-- ---------------------------------------------

      raise_application_error( -20003, pkg_rmi_traducao.extrair_proc_msg('MSG_5', 'TRG_RECCON_REC_AFTER', 'Saldo Valor Recebido menor que zero.') );

   end if;

   if :new.cd_motivo_canc is not null and :old.cd_motivo_canc is null

      and :new.DT_ESTORNO is null

   then

      vtp_quitacao := 'L';

   end if;

	 open cContaCancelada(nvl(:new.cd_itcon_rec,:old.cd_itcon_rec));

	   fetch cContaCancelada into vContaCancelada;

	 close cContaCancelada;

	 if nvl(vContaCancelada,' ') = 'X' then

	   vtp_quitacao := 'L';

	 end if;

   update dbamv.itcon_rec

      set tp_quitacao = vtp_quitacao,

          vl_soma_recebido = vvl_soma_recebido_new

    where cd_itcon_rec = nvl( :new.cd_itcon_rec, :old.cd_itcon_rec );

    If nCdContratoAdiant is not null Then

       Update dbamv.contrato_adiantamento

          Set st_contrato_adiant = NVL(vStContratoAdiant, 'C'),

              vl_saldo_recebido  = vVlSaldoRecebido

        where cd_contrato_adiant = nCdContratoAdiant;

    End If;

End TRG_RECCON_REC_AFTER;
/

