-- DROP PROCEDURE SP_SAVE_M_INFO


CREATE PROCEDURE SP_SAVE_M_INFO
       @USER_ID         NVARCHAR(64)
      ,@SERIAL          NVARCHAR(50)
      ,@MODE            INT
      ,@INFO_ID         INT
      ,@NYURYOKUSHA_FLG NVARCHAR(5)
      ,@RED_FLG         NVARCHAR(5)
AS
--保存処理実行
BEGIN
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )
    
    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --ヘッダ更新(引数→マスタ)
    UPDATE M_INFO_H
       SET M_INFO_H.NYURYOKUSHA_FLG   = @NYURYOKUSHA_FLG
          ,M_INFO_H.RED_FLG           = @RED_FLG
          ,M_INFO_H.DBS_STATUS        = W_INFO_TUCHI.DBS_STATUS
          ,M_INFO_H.DBS_UPDATE_USER   = W_INFO_TUCHI.DBS_UPDATE_USER
          ,M_INFO_H.DBS_UPDATE_DATE   = W_INFO_TUCHI.DBS_UPDATE_DATE
      FROM M_INFO_H
     INNER JOIN
           W_INFO_TUCHI
        ON W_USER_ID = @USER_ID
       AND W_SERIAL  = @SERIAL
       AND W_INFO_TUCHI.INFO_ID   = M_INFO_H.INFO_ID

    --変更前データ削除処理
    DELETE
      FROM M_INFO_B
     WHERE M_INFO_B.INFO_ID = @INFO_ID

    --ボディ保存(ワークテーブル→マスタ)
    INSERT INTO
           M_INFO_B(
                       INFO_ID
                      ,SEQ
                      ,NT_BUSHO_CD
                      ,NT_TANTO_CD
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                     )
                SELECT INFO_ID
                      ,SEQ
                      ,NT_BUSHO_CD
                      ,NT_TANTO_CD
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                  FROM W_INFO_TUCHI 
                 WHERE W_USER_ID = @USER_ID
                   AND W_SERIAL  = @SERIAL

    --ワークテーブルクリア
    DELETE
      FROM W_INFO_TUCHI
     WHERE W_INFO_TUCHI.W_USER_ID = @USER_ID
       AND W_INFO_TUCHI.W_SERIAL  = @SERIAL

    --正常終了
    INSERT INTO @TBL VALUES( 0, NULL )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_INFO_TUCHI
     WHERE W_INFO_TUCHI.W_USER_ID = @USER_ID
       AND W_INFO_TUCHI.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
