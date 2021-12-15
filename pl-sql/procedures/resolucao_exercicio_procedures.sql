CREATE OR REPLACE PROCEDURE PRC_CUBO2_ESDRAS (PRM_SEXO VARCHAR2, PRM_LETRA VARCHAR2) AS

CURSOR C_DADOS IS

  SELECT cd_paciente
          , tp_situacao
          , nm_paciente
          , tp_sexo
          , dt_cadastro
          , dt_cadastro_manual
          , cd_multi_empresa
          , sn_alt_dados_ora_app
          , sn_recebe_contato
          , sn_vip
          , sn_notificacao_sms
          , sn_endereco_sem_numero
          , sn_rut_ficticio
          , sn_oncologico
          , dt_classificacao_oncologico
  FROM paciente
  WHERE SubStr(NM_PACIENTE,0,1) = PRM_LETRA;

  vcursor_paci C_DADOS%rowtype;

  BEGIN

  DELETE PACI_CUBO2_ESDRAS
  WHERE TP_SEXO = PRM_SEXO;

  -------------LOOP DO INSERT DE PACIENTES-----------------------------
  OPEN C_DADOS; ---- ABRIR DO CURSOR (EXECUTAR O SELECT DO CURSOR)
  LOOP ---->>> INICIO DO LOOP
  fetch C_DADOS into vcursor_paci; ---- COLOCANDO OS DADOS DAQUELA LINHA DO CURSOR NA VARIAVEL
  exit when C_DADOS%notfound; ---->>>> CAUSULA DE SAIDA

 INSERT INTO PACI_CUBO2_ESDRAS (cd_paciente
                              , tp_situacao
                              , nm_paciente
                              , tp_sexo
                              , dt_cadastro
                              , dt_cadastro_manual
                              , cd_multi_empresa
                              , sn_alt_dados_ora_app
                              , sn_recebe_contato
                              , sn_vip
                              , sn_notificacao_sms
                              , sn_endereco_sem_numero
                              , sn_rut_ficticio
                              , sn_oncologico
                              , dt_classificacao_oncologico )
  VALUES (vcursor_paci.cd_paciente
        , vcursor_paci.tp_situacao
        , vcursor_paci.nm_paciente
        , vcursor_paci.tp_sexo
        , vcursor_paci.dt_cadastro
        , vcursor_paci.dt_cadastro_manual
        , vcursor_paci.cd_multi_empresa
        , vcursor_paci.sn_alt_dados_ora_app
        , vcursor_paci.sn_recebe_contato
        , vcursor_paci.sn_vip
        , vcursor_paci.sn_notificacao_sms
        , vcursor_paci.sn_endereco_sem_numero
        , vcursor_paci.sn_rut_ficticio
        , vcursor_paci.sn_oncologico
        , vcursor_paci.dt_classificacao_oncologico);

  COMMIT;

  end loop; ------>>>>> FIM DO LOOP

  CLOSE C_DADOS;

  -------------LOOP DO INSERT DE PACIENTES-----------------------------

  UPDATE PACI_CUBO2_ESDRAS
  SET TP_SITUACAO = 'S'
  WHERE SubStr(NM_PACIENTE,0,1) = 'W';


 END;
/

--- EXECUTAR A POCEDUE -----------
EXECUTE PRC_CUBO2_ESDRAS ('M','X');






       ORA-01400: cannot insert NULL into ("DBAMV"."PACI_CUBO2_ESDRAS"."DT_CADASTRO_MANUAL")
       ORA-06512: at "DBAMV.PRC_CUBO2_ESDRAS", line 35
       ORA-06512: at line 2

       begin
               PRC_CUBO2_ESDRAS ('M','X');
       end;