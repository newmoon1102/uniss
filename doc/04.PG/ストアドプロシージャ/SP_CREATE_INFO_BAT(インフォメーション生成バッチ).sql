
--DROP PROCEDURE SP_CREATE_INFO_BAT

CREATE PROCEDURE SP_CREATE_INFO_BAT
       @INFO_ID  INT

AS
--�C���t�H���[�V���������o�b�`�������s
--[���[�h] 0:�C���t�H���[�V�����f�[�^�폜 / 1:���ԕ񍐐��� / 2:���񐶐�

BEGIN

--�ϐ���`

    --�J�[�\������(�ʒm��)
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

    --�ʒm��
    DECLARE @NT_TANTO_CD NVARCHAR(10)
    --���͎Ғʒm�t���O
    DECLARE @FLG NVARCHAR(5)

--����

    --���͎Ғʒm�t���O�擾
    SET @FLG = ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                  FROM M_INFO_H
                 WHERE M_INFO_H.INFO_ID = @INFO_ID )

    --�C���t�H���[�V�����f�[�^�폜
    IF @INFO_ID = 0
      BEGIN

        --�P�N�ȏ�o�߂������ǃf�[�^�폜
        DELETE
          FROM T_INFO_R
         WHERE INFO_DATE_TIME <= DATEADD(MM,-12,getDate())

        --�����폜���[�U�[�̃f�[�^�폜
        DELETE
          FROM T_INFO
         WHERE NOT EXISTS
               ( SELECT *
                   FROM M_SHAIN
                  WHERE M_SHAIN.SHAIN_CD = T_INFO.NT_TANTO_CD )

        --�����폜���[�U�[�̊��ǃf�[�^�폜
        DELETE
          FROM T_INFO_R
         WHERE NOT EXISTS
               ( SELECT *
                   FROM M_SHAIN
                  WHERE M_SHAIN.SHAIN_CD = T_INFO_R.NT_TANTO_CD )

      END

    --���ԕ�
    ELSE IF @INFO_ID = 1
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
                  ,1
                  ,CONCAT( '="���ԕ񍐊������߂��Ă��܂��B"&CHAR(10)&"��No.�F'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,@NT_TANTO_CD
              FROM T_BUN_JUCHU_H
             --���ԕ񍐓��P <= ����
             --���̓X�e�[�^�X < ���ԕ񍐍�
             WHERE CHUKAN_DATE_1  <= CONVERT(CHAR,getDate(),111)
               AND CHUKAN_DATE_1  <> ''
               AND BUNSEKI_STS    IN ( '1','2' )
               AND NYURYOKUSHA_CD <> @NT_TANTO_CD
               AND DEL_FLG        = 'False'

             FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        END

        CLOSE TANTO_CURSOR

        --���͎Ғʒm
        IF @FLG = 'True'
          BEGIN
            --�C���t�H���[�V��������(���͎�)
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
                  ,1
                  ,CONCAT( '="���ԕ񍐊������߂��Ă��܂��B"&CHAR(10)&"��No.�F'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
              FROM T_BUN_JUCHU_H
             --���ԕ񍐓��P <= ����
             --���̓X�e�[�^�X < ���ԕ񍐍�
             WHERE CHUKAN_DATE_1 <= CONVERT(CHAR,getDate(),111)
               AND CHUKAN_DATE_1 <> ''
               AND BUNSEKI_STS   IN ( '1','2' )
               AND DEL_FLG       =  'False'

          END

      END

    --����
    ELSE IF @INFO_ID = 2
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
                  ,1
                  ,CONCAT( '="����������߂��Ă��܂��B"&CHAR(10)&"��No.�F'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,@NT_TANTO_CD
              FROM T_BUN_JUCHU_H
             --�񍐏�����/����� <= ����
             --���̓X�e�[�^�X < �����
             --����敪 <> �s�v
             WHERE KANSEI_DATE    <= CONVERT(CHAR,getDate(),111)
               AND BUNSEKI_STS    IN ( '1','2','3','4','5' )
               AND SOKUHO_KBN     <> '1'
               AND NYURYOKUSHA_CD <> @NT_TANTO_CD
               AND DEL_FLG        =  'False'

             FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        END

        CLOSE TANTO_CURSOR

        --���͎Ғʒm
        IF @FLG = 'True'
          BEGIN
            --�C���t�H���[�V��������(���͎�)
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
                  ,1
                  ,CONCAT( '="����������߂��Ă��܂��B"&CHAR(10)&"��No.�F'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
              FROM T_BUN_JUCHU_H
             --�񍐏�����/����� <= ����
             --���̓X�e�[�^�X < �����
             --����敪 <> �s�v
             WHERE KANSEI_DATE <= CONVERT(CHAR,getDate(),111)
               AND BUNSEKI_STS IN ( '1','2','3','4','5' )
               AND SOKUHO_KBN  <> '1'
               AND DEL_FLG     =  'False'

          END

      END

    DEALLOCATE TANTO_CURSOR

END

