
--DROP PROCEDURE SP_LOAD_URIAGE_JUCHU

CREATE PROCEDURE SP_LOAD_URIAGE_JUCHU
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
          FROM W_URIAGE_JUCHU
         WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

        --読込データをワークテーブルへ格納
        SET @strSQL = 'INSERT INTO '
                    + '  W_URIAGE_JUCHU '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY JURI_NO) '
                    + '        ,'  + @MODE
                    + '        ,''False''' 
                    + '        ,JUCHU_KBN_MEI '
                    + '        ,STS_MEI '
                    + '        ,BUN_HAN_KBN_MEI '
                    + '        ,JURI_NO '
                    + '        ,KENMEI '
                    + '        ,SEIKYU_CD '
                    + '        ,SEIKYU_MEI '
                    + '        ,NYURYOKUSHA_MEI '
                    + '        ,EIGYO_TANTO_MEI '
                    + '        ,NYURYOKU_DATETIME '
                    + '        ,NOHIN_DATE '
                    + '        ,EDA_KENSU '
                    + '        ,SHOHIN_KENSU '
                    + '        ,MITSU_NO '
                    + '        ,URIAGE_NO_S '
                    + '        ,HASSO_CD '
                    + '        ,JUCHU_KBN '
                    + '        ,STS '
                    + '        ,BUN_HAN_KBN '
                    + '        ,NYURYOKUSHA_CD '
                    + '        ,EIGYO_TANTO_CD '
                    + '        ,URI_MIKEIJO_FLG '
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
          FROM W_URIAGE_JUCHU
         WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

     END

END TRY


 --例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_URIAGE_JUCHU
     WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

END CATCH

END

