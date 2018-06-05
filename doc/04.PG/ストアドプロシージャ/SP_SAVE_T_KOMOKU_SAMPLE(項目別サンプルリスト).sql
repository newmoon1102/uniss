-- ���ڕʃT���v���T���v�����X�g�ۑ��X�g�A�h

-- DROP PROCEDURE SP_SAVE_T_KOMOKU_SAMPLE

CREATE PROCEDURE SP_SAVE_T_KOMOKU_SAMPLE
       @USER_ID  NVARCHAR(64)   --���[�U�[ID
      ,@SERIAL   NVARCHAR(50)   --�V���A��
      ,@MODE     INT            --�������[�h
      ,@JOKEN_W  NVARCHAR(MAX)  --�Ǎ�������
AS
--�ۑ��������s
--[���[�h] 0:�Ǎ� / 1:�ۑ� / 2:�폜

BEGIN
    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_CD       int NOT NULL
     ,RESULT_MESSAGE  NVARCHAR(max)
    )

    --�Ǎ����� ���[�N�e�[�u���h�m�r�d�q�s�p
    DECLARE @INS_SQL AS NVARCHAR(MAX)

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_BUN_KOMOKU_SAMPLE_LIST
         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

        --���[�N�e�[�u���h�m�r�d�q�s�p�r�p�k�g��
        SELECT @INS_SQL = 'INSERT INTO'
                        + '       W_BUN_KOMOKU_SAMPLE_LIST '
                        + 'SELECT '
                        + '       ''' + @USER_ID + '''' +                                             -- ���[�U�[ID
                        + '      ,''' + @SERIAL  + '''' +                                             -- �V���A��
                        + '      ,ROW_NUMBER() OVER (ORDER BY KANRYO_DATE,JURI_NO,JURI_EDA_NO,GYO_NO)  AS  W_ROW' -- �s�ԍ�
                        + '      ,0'                                                                  -- �������[�h
                        + '      ,''False'''                                                          -- �I���t���O
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.*'                                         -- ���ڕʃT���v�����X�g�r���[
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.JURI_NO'                                   -- ��No.
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_CD'                                  -- ����CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_MEI'                                 -- ������
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.NYURYOKU_DATETIME'                         -- ���͓���
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.ATENA_CD'                                  -- ����CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.ATENA'                                     -- ������
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SEIKYU_CD'                                 -- ������CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_HOHO_CD'                           -- ���͕��@CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_HOHO'                              -- ���͕��@��
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.IRAI_DATE'                                 -- �˗���
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KANRYO_DATE'                               -- ������
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KENMEI'                                    -- ����
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.MOKUTEKI'                                  -- �ړI
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KISAI_JIKO'                                -- �L�ڎ���
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_1'                            -- ���ԕ񍐓��@
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_2'                            -- ���ԕ񍐓��A
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_3'                            -- ���ԕ񍐓��B
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.H_BIKO'                                    -- ���l
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_1'                              -- �񍐐�P
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_1'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_1'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_2'                              -- �񍐐�Q
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_2'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_2'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_3'                              -- �񍐐�R
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_3'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_3'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO'                               -- �}��
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHIRYO_SHURU'                              -- �������
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHIRYO_MEI'                                -- ������
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SEQ'                                       -- SEQ
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.GYO_NO'                                    -- �s�ԍ�
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_CD'                                -- ���͍���CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_TANI'                              -- ���͍��ڒP��
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_DATA'                              -- �f�[�^
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_NO'                                -- ���͔ԍ�
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'                                 -- ���CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.STATE_MEI'                                 -- ��Ԗ�
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.K_BIKO'                                    -- ���l
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEI_DATE'                              -- �����
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD'                             -- �����CD
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_MEI'                            -- ����Җ�
                        + '      ,CASE V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'
                        + '            WHEN 1 THEN J_USER.SHAIN_CD'
                        + '            ELSE V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD'
                        + '       END'                                                                -- �����CD
                        + '      ,CASE V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'
                        + '            WHEN 1 THEN J_USER.SHIMEI'
                        + '            ELSE V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_MEI'
                        + '       END'                                                                -- ����Җ�
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_01'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_02'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_03'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_04'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_05'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_06'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_07'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_08'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_09'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_10'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_11'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_12'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_13'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_14'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_15'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_16'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_17'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_18'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_19'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_20'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_21'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_22'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_23'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_24'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_25'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_26'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.FREEWD'                                    -- �t���[���[�h
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHOHIN_BUNRUI'                             -- ���i����CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHOHIN_BUNRUI_MEI'                         -- ���i���ޖ�
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.M_BIKO'                                    -- ���i���l(���͍��ږ�)
                        + '      ,1 '                                                                 -- DBS�̈� ���R�[�h���
                        + '      ,''' + @USER_ID + ''''                                               -- DBS�̈� �쐬���[�U�h�c
                        + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'                   -- DBS�̈� �쐬����
                        + '      ,''' + @USER_ID + ''''                                               -- DBS�̈� �X�V���[�U�h�c
                        + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'                   -- DBS�̈� �X�V����
                        + '  FROM V_BUN_KOMOKU_SAMPLE_LIST '
                        + '  LEFT JOIN M_SHAIN AS J_USER '
                        + '    ON J_USER.SHAIN_CD = ''' + @USER_ID + ''''
                        + @JOKEN_W

        --���[�N�e�[�u���h�m�r�d�q�s�p�r�p�k���s
        EXEC(@INS_SQL)

      END

    --�ۑ�����
    ELSE IF @MODE = 1
      BEGIN

        --�����f�[�^�폜�i�ڍׁj
--         DELETE
--           FROM T_KOMOKU_SAMPLE
--          WHERE EXISTS
--              ( SELECT 1
--                  FROM W_BUN_KOMOKU_SAMPLE_LIST
--                 WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID       = @USER_ID
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL        = @SERIAL
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO         = T_KOMOKU_SAMPLE.JURI_NO
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO     = T_KOMOKU_SAMPLE.JURI_EDA_NO
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ             = T_KOMOKU_SAMPLE.SEQ
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.DBS_UPDATE_DATE > T_KOMOKU_SAMPLE.DBS_UPDATE_DATE
--              )

        --�����f�[�^�폜(���[�N�e�[�u���쐬�������e�[�u���X�V����)
        DELETE T_KOMOKU_SAMPLE
          FROM T_KOMOKU_SAMPLE
          LEFT OUTER JOIN W_BUN_KOMOKU_SAMPLE_LIST
            ON W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO = T_KOMOKU_SAMPLE.JURI_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO = T_KOMOKU_SAMPLE.JURI_EDA_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ = T_KOMOKU_SAMPLE.SEQ

         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID       = @USER_ID
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL        = @SERIAL
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO         = T_KOMOKU_SAMPLE.JURI_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO     = T_KOMOKU_SAMPLE.JURI_EDA_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ             = T_KOMOKU_SAMPLE.SEQ
           AND W_BUN_KOMOKU_SAMPLE_LIST.DBS_CREATE_DATE > T_KOMOKU_SAMPLE.DBS_UPDATE_DATE
           AND NOT( 
                   ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.K_BIKO,'')        = ISNULL(T_KOMOKU_SAMPLE.BIKO,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.SOKUTEI_DATE,'')  = ISNULL(T_KOMOKU_SAMPLE.SOKUTEI_DATE,'')
--               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD,'') = ISNULL(T_KOMOKU_SAMPLE.SOKUTEISHA_CD,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_01,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_01,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_02,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_02,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_03,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_03,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_04,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_04,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_05,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_05,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_06,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_06,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_07,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_07,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_08,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_08,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_09,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_09,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_10,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_10,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_11,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_11,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_12,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_12,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_13,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_13,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_14,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_14,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_15,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_15,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_16,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_16,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_17,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_17,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_18,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_18,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_19,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_19,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_20,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_20,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_21,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_21,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_22,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_22,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_23,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_23,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_24,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_24,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_25,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_25,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_26,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_26,'')
               )

        --�ۑ��Ώۃ��[�N�e�[�u���쐬�����X�V
        --�ۑ���ēǍ����s�����Ƃŕs�v�ƂȂ邪�A�v����
        UPDATE W_BUN_KOMOKU_SAMPLE_LIST
           SET W_BUN_KOMOKU_SAMPLE_LIST.DBS_CREATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
         WHERE NOT EXISTS
               ( SELECT 1
                   FROM T_KOMOKU_SAMPLE
                  WHERE T_KOMOKU_SAMPLE.JURI_NO     = W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO
                    AND T_KOMOKU_SAMPLE.JURI_EDA_NO = W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO
                    AND T_KOMOKU_SAMPLE.SEQ         = W_BUN_KOMOKU_SAMPLE_LIST.SEQ
               )
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL  = @SERIAL

        --���ڕʃT���v�����X�g(���[�N�e�[�u�����e�[�u��)
        INSERT INTO
               T_KOMOKU_SAMPLE
        SELECT 
               W_TBL.JURI_NO
              ,W_TBL.JURI_EDA_NO
              ,W_TBL.SEQ
              ,W_TBL.BUNSEKI_CD
              ,W_TBL.STATE_KBN
              ,W_TBL.K_BIKO
              ,W_TBL.SOKUTEI_DATE
              ,W_TBL.SOKUTEISHA_CD
              ,W_TBL.COLUMN_01
              ,W_TBL.COLUMN_02
              ,W_TBL.COLUMN_03
              ,W_TBL.COLUMN_04
              ,W_TBL.COLUMN_05
              ,W_TBL.COLUMN_06
              ,W_TBL.COLUMN_07
              ,W_TBL.COLUMN_08
              ,W_TBL.COLUMN_09
              ,W_TBL.COLUMN_10
              ,W_TBL.COLUMN_11
              ,W_TBL.COLUMN_12
              ,W_TBL.COLUMN_13
              ,W_TBL.COLUMN_14
              ,W_TBL.COLUMN_15
              ,W_TBL.COLUMN_16
              ,W_TBL.COLUMN_17
              ,W_TBL.COLUMN_18
              ,W_TBL.COLUMN_19
              ,W_TBL.COLUMN_20
              ,W_TBL.COLUMN_21
              ,W_TBL.COLUMN_22
              ,W_TBL.COLUMN_23
              ,W_TBL.COLUMN_24
              ,W_TBL.COLUMN_25
              ,W_TBL.COLUMN_26
              ,'1'
              ,W_TBL.DBS_CREATE_USER
              ,W_TBL.DBS_UPDATE_DATE
              ,W_TBL.DBS_UPDATE_USER
              ,W_TBL.DBS_UPDATE_DATE
          FROM W_BUN_KOMOKU_SAMPLE_LIST AS W_TBL
         WHERE NOT EXISTS
               (
               SELECT 1 
                 FROM T_KOMOKU_SAMPLE AS TBL
                WHERE TBL.JURI_NO     = W_TBL.JURI_NO
                  AND TBL.JURI_EDA_NO = W_TBL.JURI_EDA_NO
                  AND TBL.SEQ         = W_TBL.SEQ
               )
           AND W_TBL.W_USER_ID = @USER_ID
           AND W_TBL.W_SERIAL  = @SERIAL

--          WHERE NOT EXISTS
--                (
--                SELECT 1 
--                  FROM T_KOMOKU_SAMPLE AS TBL
--                 WHERE TBL.JURI_NO     = W_TBL.JURI_NO
--                   AND TBL.JURI_EDA_NO = W_TBL.JURI_EDA_NO
--                   AND TBL.SEQ         = W_TBL.SEQ
--                   AND W_TBL.W_USER_ID = @USER_ID
--                   AND W_TBL.W_SERIAL  = @SERIAL
--                )


      END

    --�폜����
    ELSE IF @MODE = 2
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_BUN_KOMOKU_SAMPLE_LIST
         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

      END


    --����I��
    INSERT INTO @TBL VALUES( 0 ,NULL )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- ��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_BUN_KOMOKU_SAMPLE_LIST
     WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
