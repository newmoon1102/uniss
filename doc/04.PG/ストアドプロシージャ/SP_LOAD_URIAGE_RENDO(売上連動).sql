--DROP PROCEDURE SP_LOAD_URIAGE_RENDO

CREATE PROCEDURE SP_LOAD_URIAGE_RENDO
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
          FROM W_URIAGE_RENDO
         WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

        --読込データをワークテーブルへ格納
        SET @strSQL = 'INSERT INTO '
                    + '  W_URIAGE_RENDO '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY URIAGE_NO ASC) '
                    + '        ,'  + @MODE
                    + '        ,''FALSE''' 
                    + '        ,TBL1.*'
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
          FROM W_URIAGE_RENDO
         WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

     END

END TRY


--例外処理
BEGIN CATCH

    --トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_URIAGE_RENDO
     WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

END CATCH

END
