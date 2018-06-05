
--DROP PROCEDURE SP_CREATE_INFO

CREATE PROCEDURE SP_CREATE_INFO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@INFO_ID  INT
AS

BEGIN

--�ϐ���`

    --�w���p�J�[�\������
    DECLARE KOBAI_TANTO_CURSOR CURSOR
        FOR SELECT M_INFO_B.NT_TANTO_CD
              FROM M_INFO_B
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_TANTO_CD) > 0
             UNION
            SELECT M_SHAIN.SHAIN_CD
              FROM M_INFO_B
              LEFT JOIN
                   M_SHAIN
                ON M_SHAIN.BUSHO_CD = M_INFO_B.NT_BUSHO_CD
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_BUSHO_CD) > 0
             UNION
            SELECT CASE
                   ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                       FROM M_INFO_H
                      WHERE M_INFO_H.INFO_ID = @INFO_ID )
                   WHEN 'True' THEN V_KOBAI_LIST.SHINSEISHA_CD
                   ELSE NULL
                   END
              FROM W_UKEIRE_KENSHU_INPUT
              LEFT JOIN
                   V_KOBAI_LIST
                ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
             WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
               AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
               AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1
               
               
    --�w���p�J�[�\���i�����m�莞�j���� 201801�ǉ�
    DECLARE KOBAI_TANTO_CURSOR_2 CURSOR
        FOR SELECT M_INFO_B.NT_TANTO_CD
              FROM M_INFO_B
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_TANTO_CD) > 0
             UNION
            SELECT M_SHAIN.SHAIN_CD
              FROM M_INFO_B
              LEFT JOIN
                   M_SHAIN
                ON M_SHAIN.BUSHO_CD = M_INFO_B.NT_BUSHO_CD
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_BUSHO_CD) > 0
             UNION
            SELECT CASE
                   ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                       FROM M_INFO_H
                      WHERE M_INFO_H.INFO_ID = @INFO_ID )
                   WHEN 'True' THEN JOINTBLA.SHINSEISHA_CD
                   ELSE NULL
                   END
              FROM W_KOBAI_CHUMON_LIST
              LEFT JOIN
                    (SELECT SHINSEISHA_CD,IRAI_NO
                   FROM V_KOBAI_LIST
                   GROUP BY IRAI_NO,SHINSEISHA_CD) AS JOINTBLA
                ON JOINTBLA.IRAI_NO = W_KOBAI_CHUMON_LIST.IRAI_NO
             WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID
               AND W_KOBAI_CHUMON_LIST.W_SERIAL  = @SERIAL


   --�w���p�J�[�\���i�����m�莞�ڍׂ��j���� 201801�ǉ�
    DECLARE KOBAI_TANTO_CURSOR_3 CURSOR
        FOR SELECT M_INFO_B.NT_TANTO_CD
              FROM M_INFO_B
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_TANTO_CD) > 0
             UNION
            SELECT M_SHAIN.SHAIN_CD
              FROM M_INFO_B
              LEFT JOIN
                   M_SHAIN
                ON M_SHAIN.BUSHO_CD = M_INFO_B.NT_BUSHO_CD
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_BUSHO_CD) > 0
             UNION
            SELECT CASE
                   ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                       FROM M_INFO_H
                      WHERE M_INFO_H.INFO_ID = @INFO_ID )
                   WHEN 'True' THEN W_KOBAI.SHINSEISHA_CD
                   ELSE NULL
                   END
              FROM W_KOBAI
             WHERE W_KOBAI.W_USER_ID = @USER_ID
               AND W_KOBAI.W_SERIAL  = @SERIAL
            
            
    --�}�X�^�o�^�p�J�[�\������
    DECLARE TANTO_CURSOR CURSOR
        FOR SELECT M_INFO_B.NT_TANTO_CD
              FROM M_INFO_B
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_TANTO_CD) > 0
             UNION
            SELECT M_SHAIN.SHAIN_CD
              FROM M_INFO_B
              LEFT JOIN
                   M_SHAIN
                ON M_SHAIN.BUSHO_CD = M_INFO_B.NT_BUSHO_CD
             WHERE M_INFO_B.INFO_ID = @INFO_ID
               AND LEN(M_INFO_B.NT_BUSHO_CD) > 0
             UNION
            SELECT @USER_ID
             WHERE ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                       FROM M_INFO_H
                      WHERE M_INFO_H.INFO_ID = @INFO_ID ) = 'True'

    --�ʒm��
    DECLARE @NT_TANTO_CD NVARCHAR(10)
    --�쐬����
    DECLARE @CREATE_DATE NVARCHAR(50)


--����

    --���������ʒm �V�K�o�^����
    IF @INFO_ID = 3
      BEGIN

        --�J�[�\���I�[�v��
        OPEN KOBAI_TANTO_CURSOR

        FETCH NEXT FROM KOBAI_TANTO_CURSOR INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�C���t�H���[�V��������
            INSERT INTO
                   T_INFO(
                            INFO_NO
                           ,INFO_ID
                           ,INFO_KBN
                           ,MESSAGE
                           ,OP_TANTO_CD
                           ,INFO_DATE_TIME 
                           ,NT_TANTO_CD
                          )
            SELECT 
                   NEXT VALUE FOR SEQ_INFO_NO
                  ,@INFO_ID
                  ,2
                  ,CONCAT( '="�ݔ������̌������s���܂����B"&CHAR(10)&"�w���\��No.�F'
                                     ,V_KOBAI_LIST.KOBAI_NO
                                     ,'"&CHAR(10)&"�w���i���F'
                                     ,V_KOBAI_LIST.KOBAIHIN_MEI
                                     ,'"&CHAR(10)&"�ݔ��Ǘ��䒠�ɓo�^���Ă��������B"' )
                  ,@USER_ID
                  --�����ϊ�
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,@NT_TANTO_CD
              FROM W_UKEIRE_KENSHU_INPUT
              LEFT JOIN
                   V_KOBAI_LIST
                ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
             WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
               AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
               AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1

             FETCH NEXT FROM KOBAI_TANTO_CURSOR INTO @NT_TANTO_CD

        END

        CLOSE KOBAI_TANTO_CURSOR
      END

    --���גʒm �V�K�o�^����
    ELSE IF @INFO_ID = 4
      BEGIN

        --�J�[�\���I�[�v��
        OPEN KOBAI_TANTO_CURSOR

        FETCH NEXT FROM KOBAI_TANTO_CURSOR INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�C���t�H���[�V��������
            INSERT INTO
                   T_INFO(
                            INFO_NO
                           ,INFO_ID
                           ,INFO_KBN
                           ,MESSAGE
                           ,OP_TANTO_CD
                           ,INFO_DATE_TIME 
                           ,NT_TANTO_CD
                          )
            SELECT 
                   NEXT VALUE FOR SEQ_INFO_NO
                  ,@INFO_ID
                  ,2
                  ,CONCAT( '="���ׂ��܂����B"&CHAR(10)&"�w���\��No.�F'
                                     ,V_KOBAI_LIST.KOBAI_NO
                                     ,'"&CHAR(10)&"�w���i���F'
                                     ,V_KOBAI_LIST.KOBAIHIN_MEI
                                     ,'"' )
                  ,@USER_ID
                  --�����ϊ�
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,@NT_TANTO_CD
              FROM W_UKEIRE_KENSHU_INPUT
              LEFT JOIN
                   V_KOBAI_LIST
                ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
             WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
               AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
               AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1

             FETCH NEXT FROM KOBAI_TANTO_CURSOR INTO @NT_TANTO_CD

        END

        CLOSE KOBAI_TANTO_CURSOR
      END

    --�w���i�}�X�^ �V�K�o�^����
    ELSE IF @INFO_ID = 5
      BEGIN

        --�J�[�\���I�[�v��
        OPEN TANTO_CURSOR

        FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�C���t�H���[�V��������
            INSERT INTO
                   T_INFO(
                            INFO_NO
                           ,INFO_ID
                           ,INFO_KBN
                           ,MESSAGE
                           ,OP_TANTO_CD
                           ,INFO_DATE_TIME 
                           ,NT_TANTO_CD
                          )
            SELECT 
                   NEXT VALUE FOR SEQ_INFO_NO
                  ,@INFO_ID
                  ,3
                  ,CONCAT( '="�w���i���o�^����܂����B"&CHAR(10)&"�w���i���F'
                                     ,W_SHOHIN.SHOHIN_MEI
                                     ,'"&CHAR(10)&"�w���iCD:'
                                     ,W_SHOHIN.SHOHIN_CD
                                     ,'"' )
                  ,@USER_ID
                  --�����ϊ�
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,@NT_TANTO_CD
              FROM W_SHOHIN
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

             FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD

        END

        CLOSE TANTO_CURSOR
      END
      
      
      
      
      --�w���\�� �����m�菈�� 201801�ǉ�
    ELSE IF @INFO_ID = 6
      BEGIN

        --�J�[�\���I�[�v��
        OPEN KOBAI_TANTO_CURSOR_2

        FETCH NEXT FROM KOBAI_TANTO_CURSOR_2 INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�C���t�H���[�V��������
            INSERT INTO
                   T_INFO(
                            INFO_NO
                           ,INFO_ID
                           ,INFO_KBN
                           ,MESSAGE
                           ,OP_TANTO_CD
                           ,INFO_DATE_TIME 
                           ,NT_TANTO_CD
                          )
            SELECT 
                   NEXT VALUE FOR SEQ_INFO_NO
                  ,@INFO_ID
                  ,2
                  ,CONCAT('="�������܂����B(�X�V�����F',FORMAT(TBLB.MTIME,'yyyy/MM/dd HH:mm:ss' )
                                     ,')"&CHAR(10)&"�w���\��No.�F'
                                     ,W_KOBAI_CHUMON_LIST.KOBAI_NO
                                     ,'"&CHAR(10)&"�w���i���F'
                                     ,W_KOBAI_CHUMON_LIST.KOBAIHIN_MEI
                                     ,'"' )
                  ,@USER_ID
                  --�����ϊ�
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,@NT_TANTO_CD
              FROM W_KOBAI_CHUMON_LIST
              LEFT JOIN
                   (SELECT KOBAIHIN_MEI,KOBAI_NO,IRAI_NO,SHINSEISHA_CD
                      FROM V_KOBAI_LIST
                  GROUP BY IRAI_NO,SHINSEISHA_CD,KOBAIHIN_MEI,KOBAI_NO) AS JOINTBLA
                ON JOINTBLA.IRAI_NO = W_KOBAI_CHUMON_LIST.IRAI_NO
              LEFT JOIN 
                  (SELECT T_KOBAI_STS_R.KOBAI_NO,T_KOBAI_STS_R.KOBAI_SEQ,TBLA.MTIME
                     FROM T_KOBAI_STS_R
                       INNER JOIN
                            (SELECT KOBAI_NO,KOBAI_SEQ,MAX(MOD_DATE_TIME) AS MTIME 
                               FROM T_KOBAI_STS_R
                           GROUP BY KOBAI_NO,KOBAI_SEQ) TBLA
                       ON T_KOBAI_STS_R.KOBAI_NO       = TBLA.KOBAI_NO
                       AND T_KOBAI_STS_R.KOBAI_SEQ     = TBLA.KOBAI_SEQ
                       AND T_KOBAI_STS_R.MOD_DATE_TIME = TBLA.MTIME
                     WHERE AFTER_STS = '3') TBLB
                ON W_KOBAI_CHUMON_LIST.KOBAI_NO   = TBLB.KOBAI_NO
                AND W_KOBAI_CHUMON_LIST.KOBAI_SEQ = TBLB.KOBAI_SEQ
             WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID
               AND W_KOBAI_CHUMON_LIST.W_SERIAL  = @SERIAL
               AND W_KOBAI_CHUMON_LIST.SHINSEISHA_CD  = @NT_TANTO_CD
               AND W_KOBAI_CHUMON_LIST.SELECT_FLG           =  'True'
               AND ISNULL(W_KOBAI_CHUMON_LIST.CHUMON_NO,'') =  ''
               AND W_KOBAI_CHUMON_LIST.KOBAI_KBN            IN  ('1','3','4')

             FETCH NEXT FROM KOBAI_TANTO_CURSOR_2 INTO @NT_TANTO_CD

        END

        CLOSE KOBAI_TANTO_CURSOR_2
      END


      --�w���\�� �����m�菈��(�ڍׂ��) 201801�ǉ�
    ELSE IF @INFO_ID = 7
      BEGIN

        --�J�[�\���I�[�v��
        OPEN KOBAI_TANTO_CURSOR_3

        FETCH NEXT FROM KOBAI_TANTO_CURSOR_3 INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�C���t�H���[�V��������
            INSERT INTO
                   T_INFO(
                            INFO_NO
                           ,INFO_ID
                           ,INFO_KBN
                           ,MESSAGE
                           ,OP_TANTO_CD
                           ,INFO_DATE_TIME 
                           ,NT_TANTO_CD
                          )
            SELECT 
                   NEXT VALUE FOR SEQ_INFO_NO
                  ,@INFO_ID
                  ,2
                  ,CONCAT( '="�������܂����B(�X�V�����F',FORMAT(TBLB.MTIME,'yyyy/MM/dd HH:mm:ss' )
                                     ,')"&CHAR(10)&"�w���\��No.�F'
                                     ,W_KOBAI.KOBAI_NO
                                     ,'"&CHAR(10)&"�w���i���F'
                                     ,W_KOBAI.KOBAIHIN_MEI
                                     ,'"' )
                  ,@USER_ID
                  --�����ϊ�
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,@NT_TANTO_CD
              FROM W_KOBAI 
                  LEFT JOIN 
                  (SELECT T_KOBAI_STS_R.KOBAI_NO,T_KOBAI_STS_R.KOBAI_SEQ,TBLA.MTIME
                     FROM T_KOBAI_STS_R
                       INNER JOIN
                            (SELECT KOBAI_NO,KOBAI_SEQ,MAX(MOD_DATE_TIME) AS MTIME 
                               FROM T_KOBAI_STS_R
                           GROUP BY KOBAI_NO,KOBAI_SEQ) TBLA
                       ON T_KOBAI_STS_R.KOBAI_NO       = TBLA.KOBAI_NO
                       AND T_KOBAI_STS_R.KOBAI_SEQ     = TBLA.KOBAI_SEQ
                       AND T_KOBAI_STS_R.MOD_DATE_TIME = TBLA.MTIME
                      WHERE AFTER_STS = '3') TBLB
                     ON W_KOBAI.KOBAI_NO   = TBLB.KOBAI_NO
                     AND W_KOBAI.KOBAI_SEQ = TBLB.KOBAI_SEQ
             WHERE 
               W_KOBAI.W_USER_ID = @USER_ID
               AND W_KOBAI.W_SERIAL  = @SERIAL
               AND W_KOBAI.SHINSEISHA_CD  = @NT_TANTO_CD
               AND W_KOBAI.KOBAI_KBN            IN  ('1','3','4')
               AND W_KOBAI.W_MODE    IN ('1','2')
               AND W_KOBAI.KOBAI_STS = '3'

             FETCH NEXT FROM KOBAI_TANTO_CURSOR_3 INTO @NT_TANTO_CD

        END

        CLOSE KOBAI_TANTO_CURSOR_3
      END
      
    DEALLOCATE KOBAI_TANTO_CURSOR
    DEALLOCATE TANTO_CURSOR
    DEALLOCATE KOBAI_TANTO_CURSOR_2
    DEALLOCATE KOBAI_TANTO_CURSOR_3

END


