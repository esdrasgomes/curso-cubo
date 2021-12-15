DECLARE
  mCdModulo VARCHAR2(60) := 'M_CUBOS2_VALIACAO_CUBO_EGS'; 
  mDescModulo VARCHAR2(100) := 'Tela da avaliação do curso CUBO 2';
  mDescSistem VARCHAR2(100) := 'FFCV';
BEGIN
    FOR rReg IN( SELECT DS_URL_SERVIDOR
                       ,DS_URL_SERV_RELATORIO
                       ,DS_URL_SERVIDOR_HTML
                       ,DS_URL_SERV_RELATORIO_HTML
                       ,DS_URL_SERVIDOR_FLEX
                       ,DS_URL_SERV_RELATORIO_FLEX
                   FROM DBASGU.PRODUTO_SISTEMA
                  WHERE CD_PRODUTO = 'SUPRI'
                    AND NOT EXISTS (SELECT 1 FROM DBASGU.PRODUTO_SISTEMA WHERE CD_PRODUTO = mDescSistem)
                )
    LOOP
      --
      INSERT INTO DBASGU.PRODUTO_SISTEMA (CD_PRODUTO
                                       ,NM_PRODUTO
                                       ,DS_PRODUTO
                                       ,DH_REGISTRO
                                       ,TP_PLATAFORMA
                                       ,SN_LINK_EXT
                                       ,SN_FOUNDATION
                                       ,DS_URL_SERVIDOR
                                       ,DS_URL_SERV_RELATORIO
                                       ,DS_URL_SERVIDOR_HTML
                                       ,DS_URL_SERV_RELATORIO_HTML
                                       ,DS_URL_SERVIDOR_FLEX
                                       ,DS_URL_SERV_RELATORIO_FLEX
                                       )
                                VALUES
                                       ('FFCV'
                                       ,'GERENCIAMENTO DE UNIDADE'
                                       ,'Produtos vinculados ao Gerenciamento de Unidade.'
                                       ,SYSDATE  --dh_registro
                                       ,'MV2000' --tp_plataforma
                                       ,'N' --sn_link_ext
                                       ,'S' --sn_foundation
                                       ,rReg.DS_URL_SERVIDOR
                                       ,rReg.DS_URL_SERV_RELATORIO
                                       ,rReg.DS_URL_SERVIDOR_HTML
                                       ,rReg.DS_URL_SERV_RELATORIO_HTML
                                       ,rReg.DS_URL_SERVIDOR_FLEX
                                       ,rReg.DS_URL_SERV_RELATORIO_FLEX
                                       );
    END LOOP;
    --
    FOR rReg IN( SELECT Count(1) VAL
                   FROM DBASGU.SISTEMA
                  WHERE CD_SISTEMA = 'MGES'
                )
    LOOP
      IF (rReg.VAL = 0) THEN
        --
        INSERT INTO DBASGU.SISTEMA (CD_SISTEMA,NM_SISTEMA,TP_PLATAFORMA,SN_ATIVO,CD_PRODUTO)
                            VALUES (mDescSistem,'SISTEMA DE GERENCIAMENTO DA UNIDADE','O','S',mDescSistem);
        --
      END IF;
    END LOOP;
    --
    COMMIT;
    --
    BEGIN
      INSERT INTO DBASGU.MODULOS (CD_MODULO,NM_MODULO,TP_MODULO,DT_CRIACAO,CD_SISTEMA_DONO)
                          VALUES (mCdModulo, mDescModulo, 'F', TRUNC(sysdate), mDescSistem);
    EXCEPTION
      WHEN OTHERS THEN
        Dbms_Output.Put_Line('Modulo já cadastrado!('||mCdModulo||')');
    END;
    --
    BEGIN
      INSERT INTO DBASGU.AUT_MOD (CD_USUARIO,CD_MODULO,SN_CONSULTAR,SN_ALTERAR,SN_EXCLUIR,SN_INCLUIR)
                          VALUES ('DBAMV',mCdModulo,'S','S','S','S');
    EXCEPTION
      WHEN OTHERS THEN
        Dbms_Output.Put_Line('Autorização Modulo já cadastrado!('||mCdModulo||')');
    END;
    --
    FOR rReg IN (SELECT PU.CD_PAPEL
                   FROM DBASGU.PAPEL_USUARIOS PU
                       ,DBASGU.PAPEL P
                  WHERE PU.CD_USUARIO = 'DBAMV'
                    AND P.SN_ATIVO    = 'S'
                  ORDER BY PU.CD_PAPEL DESC)
    LOOP
      --
      BEGIN
        INSERT INTO DBASGU.PAPEL_MOD (CD_PAPEL,CD_MODULO,SN_CONSULTAR,SN_ALTERAR,SN_EXCLUIR,SN_INCLUIR)
                              VALUES (379,mCdModulo,'S','S','S','S' );
      EXCEPTION
        WHEN OTHERS THEN
          Dbms_Output.Put_Line('Papel Modulo já cadastrado!('||mCdModulo||')');
      END;
      --
      EXIT;
      --
    END LOOP;
    --
    COMMIT;
    --
END;
/