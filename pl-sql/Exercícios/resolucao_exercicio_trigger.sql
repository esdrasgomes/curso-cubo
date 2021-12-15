CREATE TABLE DBAMV.VAL_PRO_ESDRAS_LOG AS SELECT * FROM VAL_PRO_BKP

DELETE VAL_PRO_ESDRAS_LOG

ALTER TABLE DBAMV.VAL_PRO_ESDRAS_LOG ADD USUARIO VARCHAR2(20)

TP_ALTERACAO VARCHAR2(20)   DT_ALTERACAO DATE

-------------------------------------------------------------------------

PROMPT CREATE OR REPLACE TRIGGER trg_val_pro_esdras
CREATE OR REPLACE TRIGGER trg_cubo_esdras
AFTER  --- ANTES (BEFORE) OU DEPOIS (AFTER) DO EVENTO
UPDATE OR DELETE OR INSERT  --DIZ O TIPO DE OPERA??O
ON VAL_PRO_ESDRAS_LOG --DEFINE A TABELA QUE TERA A TRIGGER
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE

VARIAVEL  NUMBER;

BEGIN

IF UPDATING THEN

 INSERT INTO VAL_PRO_ESDRAS_LOG
             ( cd_tab_fat
              , cd_pro_fat
              , dt_vigencia
              , vl_honorario
              , vl_operacional
              , vl_total
              , cd_import
              , vl_sh
              , vl_sd
              , qt_pontos
              , qt_pontos_anest
              , sn_ativo
              , nm_usuario
              , dt_ativacao
              , cd_seq_integra
              , dt_integra
              , cd_contrato
              , cd_import_simpro
              , tp_dml
              , dt_alteracao
              , usuario ) --O UPDATE ? O UNICO QUE POSSUE O NEW E O OLD
  VALUES (  NVL(:NEW.cd_tab_fat           , :OLD.cd_tab_fat      )
          , NVL(:NEW.cd_pro_fat           , :OLD.cd_pro_fat      )
          , NVL(:NEW.dt_vigencia          , :OLD.dt_vigencia     )
          , NVL(:NEW.vl_honorario         , :OLD.vl_honorario    )
          , NVL(:NEW.vl_operacional       , :OLD.vl_operacional  )
          , NVL(:NEW.vl_total             , :OLD.vl_total        )
          , NVL(:NEW.cd_import            , :OLD.cd_import       )
          , NVL(:NEW.vl_sh                , :OLD.vl_sh           )
          , NVL(:NEW.vl_sd                , :OLD.vl_sd           )
          , NVL(:NEW.qt_pontos            , :OLD.qt_pontos       )
          , NVL(:NEW.qt_pontos_anest      , :OLD.qt_pontos_anest )
          , NVL(:NEW.sn_ativo             , :OLD.sn_ativo        )
          , NVL(:NEW.nm_usuario           , :OLD.nm_usuario      )
          , NVL(:NEW.dt_ativacao          , :OLD.dt_ativacao     )
          , NVL(:NEW.cd_seq_integra       , :OLD.cd_seq_integra  )
          , NVL(:NEW.dt_integra           , :OLD.dt_integra      )
          , NVL(:NEW.cd_contrato          , :OLD.cd_contrato     )
          , NVL(:NEW.cd_import_simpro     , :OLD.cd_import_simpro)
          , SYSDATE
          , 'UPDATE'
          , USER );

ELSIF DELETING THEN  --NO CASO DO DELETING ELE S? VAI POSSUIR O OLD, POIS O NEW NAO EXISTE

INSERT INTO VAL_PRO_ESDRAS_LOG ( cd_tab_fat
                                , cd_pro_fat
                                , dt_vigencia
                                , vl_honorario
                                , vl_operacional
                                , vl_total
                                , cd_import
                                , vl_sh
                                , vl_sd
                                , qt_pontos
                                , qt_pontos_anest
                                , sn_ativo
                                , nm_usuario
                                , dt_ativacao
                                , cd_seq_integra
                                , dt_integra
                                , cd_contrato
                                , cd_import_simpro
                                , tp_dml
                                , dt_alteracao
                                , usuario )
                     VALUES ( :OLD.cd_tab_fat
                            , :OLD.cd_pro_fat
                            , :OLD.dt_vigencia
                            , :OLD.vl_honorario
                            , :OLD.vl_operacional
                            , :OLD.vl_total
                            , :OLD.cd_import
                            , :OLD.vl_sh
                            , :OLD.vl_sd
                            , :OLD.qt_pontos
                            , :OLD.qt_pontos_anest
                            , :OLD.sn_ativo
                            , :OLD.nm_usuario
                            , :OLD.dt_ativacao
                            , :OLD.cd_seq_integra
                            , :OLD.dt_integra
                            , :OLD.cd_contrato
                            , :OLD.cd_import_simpro
                            , 'DELETE'
                            , SYSDATE
                            , USER);

ELSIF INSERTING THEN  --NO CASO DO INSERTING ELE S? VAI POSSUIR O NEW, POIS O OLD NAO EXISTE

   INSERT INTO VAL_PRO_ESDRAS_LOG ( cd_tab_fat
                                  , cd_pro_fat
                                  , dt_vigencia
                                  , vl_honorario
                                  , vl_operacional
                                  , vl_total
                                  , cd_import
                                  , vl_sh
                                  , vl_sd
                                  , qt_pontos
                                  , qt_pontos_anest
                                  , sn_ativo
                                  , nm_usuario
                                  , dt_ativacao
                                  , cd_seq_integra
                                  , dt_integra
                                  , cd_contrato
                                  , cd_import_simpro
                                  , tp_dml
                                  , dt_alteracao
                                  , usuario )
                     VALUES ( :NEW.cd_tab_fat
                            , :NEW.cd_pro_fat
                            , :NEW.dt_vigencia
                            , :NEW.vl_honorario
                            , :NEW.vl_operacional
                            , :NEW.vl_total
                            , :NEW.cd_import
                            , :NEW.vl_sh
                            , :NEW.vl_sd
                            , :NEW.qt_pontos
                            , :NEW.qt_pontos_anest
                            , :NEW.sn_ativo
                            , :NEW.nm_usuario
                            , :NEW.dt_ativacao
                            , :NEW.cd_seq_integra
                            , :NEW.dt_integra
                            , :NEW.cd_contrato
                            , :NEW.cd_import_simpro
                            , 'INSERT'
                            , SYSDATE
                            , USER);

END IF;

END;
/

