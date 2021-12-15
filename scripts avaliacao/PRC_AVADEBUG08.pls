PROMPT CREATE OR REPLACE PROCEDURE prc_avadebug08
CREATE OR REPLACE PROCEDURE prc_avadebug08 (tpMovimentacao VARCHAR2,

									 cdAmostra 			NUMBER,

									 cdAtendimento NUMBER,

									 cdPedido NUMBER,

									 cdItpedLab NUMBER,

									 cdExame NUMBER,

									 dtMovimentacao DATE DEFAULT NULL,

									 dtColetaOld DATE DEFAULT NULL,

									 dtColetaNew DATE DEFAULT NULL,

									 cdRecepcao NUMBER DEFAULT NULL,

									 cdRecepcaoMaquina NUMBER DEFAULT NULL,

									 cdLoteBancada NUMBER DEFAULT NULL) IS

	--Constantes

	OBJETO CONSTANT VARCHAR2(30) := 'PRC_PSSD_LOG_AMOSTRA';



	COLETA_SETOR CONSTANT VARCHAR2(50) := 'COLETA_SETOR';

	CONFIRMACAO_LAB CONSTANT  VARCHAR2(50) := 'CONFIRMACAO_LAB';

	UPDATE_DATA_COLETA CONSTANT  VARCHAR2(50) := 'UPDATE_DATA_COLETA';

	ADD_MAPA_TRABALHO CONSTANT  VARCHAR2(50) := 'ADD_MAPA_TRABALHO';

	ENTREGUE_LAB CONSTANT VARCHAR2(50) := 'ENTREGUE_LAB';

	ENTREGUA_CANCELADA CONSTANT VARCHAR2(50) := 'ENTREGUA_CANCELADA';

	AMOSTRA_DESCARTADA CONSTANT VARCHAR2(50) := 'AMOSTRA_DESCARTADA';

	CANCELADA_SETOR CONSTANT VARCHAR2(50) := 'CANCELADA_SETOR';

	CANCELADA_LAB  CONSTANT VARCHAR2(50) := 'CANCELADA_LAB';

	RECOLETA CONSTANT VARCHAR2(50) := 'RECOLETA';

	AMOSTRA_ROTEADA  CONSTANT VARCHAR2(50) := 'AMOSTRA_ROTEADA';

	ARQUIVO_GERADO  CONSTANT VARCHAR2(50) := 'ARQUIVO_GERADO';





	dsMovimentacao varchar2(400);

	snCanceladoSetor varchar2(1) := 'N';

	snCanceladoLab varchar2(1) := 'N';



  	CURSOR cPedido(pCdAmostra NUMBER) IS

	    SELECT PED_LAB.CD_ATENDIMENTO

	          ,ITPED_LAB.CD_PED_LAB

	          ,ITPED_LAB.CD_ITPED_LAB

	          ,ITPED_LAB.CD_EXA_LAB

	      FROM DBAMV.AMOSTRA_EXA_LAB

	          ,DBAMV.ITPED_LAB

	          ,DBAMV.PED_LAB

	     WHERE AMOSTRA_EXA_LAB.CD_AMOSTRA = pCdAmostra

	       AND AMOSTRA_EXA_LAB.CD_ITPED_LAB = ITPED_LAB.CD_ITPED_LAB

	       AND ITPED_LAB.CD_PED_LAB = PED_LAB.CD_PED_LAB;



  	CURSOR cRecepcao(cdRecepcao NUMBER) IS

  	SELECT DS_RECEPCAO_AMOSTRA FROM dbamv.recepcao_amostra

  		where  CD_RECEPCAO_AMOSTRA = cdRecepcao;

 	 dsRecepcao varchar(400);



BEGIN

	Dbms_Output.Put_Line('Gravando log:'|| tpMovimentacao);



	IF COLETA_SETOR  = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_1', OBJETO,'Amostra associada ao exame foi colhida no Setor. Amostra : %s',arg_list(cdAmostra));



	elsif CONFIRMACAO_LAB  = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_2', OBJETO,'Amostra associada ao exame foi recepcionada/colhida pelo Laboratorio. Amostra : %s',arg_list(cdAmostra));



		if cdRecepcao is not null then

			OPEN cRecepcao(cdRecepcao);

				FETCH cRecepcao INTO dsRecepcao;

			CLOSE cRecepcao;

			dsMovimentacao := dsMovimentacao||pkg_rmi_traducao.extrair_pkg_msg('MSG_3', OBJETO,'Recepc?o: %s',arg_list(dsRecepcao));

		end if;

	elsif UPDATE_DATA_COLETA = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_4', OBJETO,'Alterada a Data da Coleta de %s para %s. Amostra : %s',arg_list(to_char(dtColetaOld,'DD/MM/YYYY HH:MI'),to_char(dtColetaNew,'DD/MM/YYYY HH:MI'),cdAmostra ));



--	elsif ADD_MAPA_TRABALHO  = tpMovimentacao THEN

	--	dsMovimentacao := pkg_rmi.extrair_pkg_msg('MSG_5', OBJETO,'Exame associado ao Mapa de Trabalho : %s. Amostra : %s',arg_list(cdLotebancada,cdAmostra ));



	elsif ENTREGUE_LAB  = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_6', OBJETO,'Amostra associada ao exame foi entregue ao Laboratorio. Amostra : %s',arg_list(cdAmostra));



	elsif ENTREGUA_CANCELADA = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_7', OBJETO,'Amostra associada ao exame foi cancelada a entrega. Amostra : %s',arg_list(cdAmostra));



	elsif AMOSTRA_DESCARTADA  = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_8', OBJETO,'Amostra associada ao exame foi descartada. Amostra : %s',arg_list(cdAmostra ));



	ELSIF CANCELADA_SETOR  = tpMovimentacao THEN

		snCanceladoSetor := 'S';

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_9', OBJETO,'Amostra cancelada pelo Setor. Amostra: %s',arg_list(cdAmostra));



	ELSIF CANCELADA_LAB = tpMovimentacao THEN

		snCanceladoLab := 'S';

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_10', OBJETO,'Amostra cancelada pelo Laboratorio. Amostra: %s',arg_list(cdAmostra));



	ELSIF RECOLETA = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_11', OBJETO,'Exame incluido numa nova Amostra :%s. (Recoleta)',arg_list(cdAmostra));



	ELSIF AMOSTRA_ROTEADA = tpMovimentacao THEN

		OPEN cRecepcao(cdRecepcao);

			FETCH cRecepcao INTO dsRecepcao;

		CLOSE cRecepcao;



		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_12', OBJETO,'A amostra: %s, associada ao exame, passou pela recepc?o de amostra: %s',arg_list(cdAmostra,dsRecepcao));

		OPEN cRecepcao(cdRecepcaoMaquina);

			FETCH cRecepcao INTO dsRecepcao;

		CLOSE cRecepcao;

		 dsMovimentacao := dsMovimentacao||pkg_rmi_traducao.extrair_pkg_msg('MSG_13', OBJETO,'. N?o foi possivel confirmar, pois essa amostra deve ser direcionada para a recepc?o: %s',arg_list(dsRecepcao));



	ELSIF ARQUIVO_GERADO = tpMovimentacao THEN

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_14', OBJETO,'Gerac?o do Arquivo de Interfaceamento');



	ELSE

		dsMovimentacao := pkg_rmi_traducao.extrair_pkg_msg('MSG_15', OBJETO,'Log invalido.');

		Raise_Application_Error(-20999,dsMovimentacao);

	END IF;

	INSERT INTO DBAMV.LOG_MOVIMENTO_EXAME ( CD_LOG_MOVIMENTO_EXAME

	                                      ,CD_ATENDIMENTO

	                                      ,CD_PED_LAB_RX

                                        ,CD_ITPED_LAB_RX

                                        ,CD_EXA_LAB

                                        ,CD_EXA_RX

                                        ,TP_EXAME

                                        ,DS_MOVIMENTO

                                        ,DT_MOVIMENTO

                                        ,HR_MOVIMENTO

                                        ,CD_USUARIO_RESPONSAVEL

                                        ,CD_AMOSTRA

                                        ,SN_CANCELADO_SETOR

                                        ,SN_CANCELADO_LAB

                                        ,NM_RESPONSAVEL )

	                             VALUES (dbamv.SEQ_LOG_MOVIMENTO_EXAME.NEXTVAL

	                                      ,100

	                                      ,10

                                        ,20

                                        ,30

                                        ,40

                                        ,'A'

                                        ,'DECRICAO'

                                        ,SYSDATE --Nvl(DT_MOVIMENTO,sysdate)

                                        ,SYSDATE

                                        ,50

                                        ,60

                                        ,'S'

                                        ,'N'

                                        ,'ESDRAS');


END;
/

