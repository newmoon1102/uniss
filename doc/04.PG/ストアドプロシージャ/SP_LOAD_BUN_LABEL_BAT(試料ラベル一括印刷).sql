--DROP PROCEDURE SP_LOAD_BUN_LABEL_BAT

CREATE PROCEDURE SP_LOAD_BUN_LABEL_BAT
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     NVARCHAR(1)
      ,@SQL      NVARCHAR(max)
AS
--[モード] 0:読込 / 1:ワークテーブル削除
BEGIN

--変数定義
    DECLARE @strSQL NVARCHAR(max)

--セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --読込処理
    IF @MODE = 0
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_LABEL_BAT
         WHERE W_BUN_LABEL_BAT.W_USER_ID = @USER_ID

        --読込データをワークテーブルへ格納
        SET @strSQL = 'INSERT INTO '
                    + '  W_BUN_LABEL_BAT '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY JURI_NO,JURI_EDA_NO) '
                    + '        ,'  + @MODE
                    + '        ,''False''' 
                    + '        ,BUNSEKI_STS_MEI '
                    + '        ,JUCHU_KBN_MEI '
                    + '        ,JURI_NO '
                    + '        ,JURI_EDA_NO '
                    + '        ,KEISHIKI_KBN_MEI '
                    + '        ,EIGYO_TANTO_MEI '
                    + '        ,NYURYOKUSHA_MEI '
                    + '        ,IRAI_DATE '
                    + '        ,CHUKAN_DATE_1 '
                    + '        ,CHUKAN_DATE_2 '
                    + '        ,CHUKAN_DATE_3 '
                    + '        ,KANSEI_DATE '
                    + '        ,NOHIN_DATE '
                    + '        ,ATENA_CD '
                    + '        ,ATENA '
                    + '        ,SEIKYU_CD '
                    + '        ,SEIKYU_MEI '
                    + '        ,MITSU_NO '
                    + '        ,SHIRYO_SHURUI '
                    + '        ,SHIRYO_MEI '
                    + '        ,NYURYOKU_DATETIME '
                    + '        ,BUNSEKI_STS '
                    + '        ,JUCHU_KBN '
                    + '        ,KEISHIKI_KBN '
                    + '        ,EIGYO_TANTO_CD '
                    + '        ,NYURYOKUSHA_CD '
                    + '        ,FREEWD '
                    + '        ,1 '
                    + '        ,'''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '        , '''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '  FROM' + '(' + @SQL + ') TBL1'
        EXEC(@strSQL)
      END

    --ワークテーブル削除処理
    ELSE IF @MODE = 1
     BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_LABEL_BAT
         WHERE W_BUN_LABEL_BAT.W_USER_ID = @USER_ID

     END

END TRY


 --例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_BUN_LABEL_BAT
     WHERE W_BUN_LABEL_BAT.W_USER_ID = @USER_ID

END CATCH

END
