-- DROP PROCEDURE SP_SAVE_M_AITESAKI


CREATE PROCEDURE SP_SAVE_M_AITESAKI
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
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

    --新規登録処理
    IF @MODE = 1
      BEGIN
        --新規保存(ワークテーブル→マスタ)
        INSERT INTO
               M_AITESAKI(
                        AITE_CD
                       ,AITE_MEI
                       ,YUBIN_NO
                       ,ADDRESS_1
                       ,ADDRESS_2
                       ,TEL
                       ,FAX
                       ,MAIL
                       ,BUSHO_MEI
                       ,TANTO_MEI
                       ,KEISHO
                       ,BIKO
                       ,SEIKYU_FLG
                       ,SHIRE_FLG
                       ,HASSO_FLG
                       ,HOKOKU_FLG
                       ,MAKER_FLG
                       ,GAICHU_FLG
                       ,KANKO_FLG
                       ,DOGYO_FLG
                       ,SPOT_FLG
                       ,EIGYO_TANTO_CD
                       ,SEIKYU_BUNRUI
                       ,SEIKYU_CHUKI
                       ,SEIKYUHOHO_KBN
                       ,KAISHU_KBN
                       ,KAISHU_MONTH
                       ,KAISHU_DAY
                       ,TAX_KBN
                       ,SEIKYUSHO_FLG
                       ,JURYOSHO_FLG
                       ,NOHINSHO_FLG
                       ,HIKAE_FLG
                       ,SEIKYU_HASU_KBN
                       ,SEIKYU_TESURYO_KBN
                       ,SHIHARAIHOHO_KBN
                       ,SHIIRE_CHUKI
                       ,SHIIRE_HASU_KBN
                       ,SHIIRE_TESURYO_KBN
                       ,LINK_DATETIME
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT AITE_CD
                       ,AITE_MEI
                       ,YUBIN_NO
                       ,ADDRESS_1
                       ,ADDRESS_2
                       ,TEL
                       ,FAX
                       ,MAIL
                       ,BUSHO_MEI
                       ,TANTO_MEI
                       ,KEISHO
                       ,BIKO
                       ,SEIKYU_FLG
                       ,SHIRE_FLG
                       ,HASSO_FLG
                       ,HOKOKU_FLG
                       ,MAKER_FLG
                       ,GAICHU_FLG
                       ,KANKO_FLG
                       ,DOGYO_FLG
                       ,SPOT_FLG
                       ,EIGYO_TANTO_CD
                       ,SEIKYU_BUNRUI
                       ,SEIKYU_CHUKI
                       ,SEIKYUHOHO_KBN
                       ,KAISHU_KBN
                       ,KAISHU_MONTH
                       ,KAISHU_DAY
                       ,TAX_KBN
                       ,SEIKYUSHO_FLG
                       ,JURYOSHO_FLG
                       ,NOHINSHO_FLG
                       ,HIKAE_FLG
                       ,SEIKYU_HASU_KBN
                       ,SEIKYU_TESURYO_KBN
                       ,SHIHARAIHOHO_KBN
                       ,SHIIRE_CHUKI
                       ,SHIIRE_HASU_KBN
                       ,SHIIRE_TESURYO_KBN
                       ,LINK_DATETIME
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_AITESAKI 
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
      END
    
    --更新処理
    ELSE IF @MODE = 2
      BEGIN
    --保存(ワークテーブル→マスタ)
        UPDATE M_AITESAKI
           SET M_AITESAKI.AITE_CD           = W_AITESAKI.AITE_CD
              ,M_AITESAKI.AITE_MEI          = W_AITESAKI.AITE_MEI
              ,M_AITESAKI.YUBIN_NO          = W_AITESAKI.YUBIN_NO
              ,M_AITESAKI.ADDRESS_1         = W_AITESAKI.ADDRESS_1
              ,M_AITESAKI.ADDRESS_2         = W_AITESAKI.ADDRESS_2
              ,M_AITESAKI.TEL               = W_AITESAKI.TEL
              ,M_AITESAKI.FAX               = W_AITESAKI.FAX
              ,M_AITESAKI.MAIL              = W_AITESAKI.MAIL
              ,M_AITESAKI.BUSHO_MEI         = W_AITESAKI.BUSHO_MEI
              ,M_AITESAKI.TANTO_MEI         = W_AITESAKI.TANTO_MEI
              ,M_AITESAKI.KEISHO            = W_AITESAKI.KEISHO
              ,M_AITESAKI.BIKO              = W_AITESAKI.BIKO
              ,M_AITESAKI.SEIKYU_FLG        = W_AITESAKI.SEIKYU_FLG
              ,M_AITESAKI.SHIRE_FLG         = W_AITESAKI.SHIRE_FLG
              ,M_AITESAKI.HASSO_FLG         = W_AITESAKI.HASSO_FLG
              ,M_AITESAKI.HOKOKU_FLG        = W_AITESAKI.HOKOKU_FLG
              ,M_AITESAKI.MAKER_FLG         = W_AITESAKI.MAKER_FLG
              ,M_AITESAKI.GAICHU_FLG        = W_AITESAKI.GAICHU_FLG
              ,M_AITESAKI.KANKO_FLG         = W_AITESAKI.KANKO_FLG
              ,M_AITESAKI.DOGYO_FLG         = W_AITESAKI.DOGYO_FLG
              ,M_AITESAKI.SPOT_FLG          = W_AITESAKI.SPOT_FLG
              ,M_AITESAKI.EIGYO_TANTO_CD    = W_AITESAKI.EIGYO_TANTO_CD
              ,M_AITESAKI.SEIKYU_BUNRUI     = W_AITESAKI.SEIKYU_BUNRUI
              ,M_AITESAKI.SEIKYU_CHUKI      = W_AITESAKI.SEIKYU_CHUKI
              ,M_AITESAKI.SEIKYUHOHO_KBN    = W_AITESAKI.SEIKYUHOHO_KBN
              ,M_AITESAKI.KAISHU_KBN        = W_AITESAKI.KAISHU_KBN
              ,M_AITESAKI.KAISHU_MONTH      = W_AITESAKI.KAISHU_MONTH
              ,M_AITESAKI.KAISHU_DAY        = W_AITESAKI.KAISHU_DAY
              ,M_AITESAKI.TAX_KBN           = W_AITESAKI.TAX_KBN
              ,M_AITESAKI.SEIKYUSHO_FLG     = W_AITESAKI.SEIKYUSHO_FLG
              ,M_AITESAKI.JURYOSHO_FLG      = W_AITESAKI.JURYOSHO_FLG
              ,M_AITESAKI.NOHINSHO_FLG      = W_AITESAKI.NOHINSHO_FLG
              ,M_AITESAKI.HIKAE_FLG         = W_AITESAKI.HIKAE_FLG
              ,M_AITESAKI.SEIKYU_HASU_KBN   = W_AITESAKI.SEIKYU_HASU_KBN
              ,M_AITESAKI.SEIKYU_TESURYO_KBN= W_AITESAKI.SEIKYU_TESURYO_KBN
              ,M_AITESAKI.SHIHARAIHOHO_KBN  = W_AITESAKI.SHIHARAIHOHO_KBN
              ,M_AITESAKI.SHIIRE_CHUKI      = W_AITESAKI.SHIIRE_CHUKI
              ,M_AITESAKI.SHIIRE_HASU_KBN   = W_AITESAKI.SHIIRE_HASU_KBN
              ,M_AITESAKI.SHIIRE_TESURYO_KBN= W_AITESAKI.SHIIRE_TESURYO_KBN
              ,M_AITESAKI.LINK_DATETIME     = W_AITESAKI.LINK_DATETIME
              ,M_AITESAKI.MISHIYO_FLG       = W_AITESAKI.MISHIYO_FLG
              ,M_AITESAKI.DBS_STATUS        = W_AITESAKI.DBS_STATUS
              ,M_AITESAKI.DBS_UPDATE_USER   = W_AITESAKI.DBS_UPDATE_USER
              ,M_AITESAKI.DBS_UPDATE_DATE   = W_AITESAKI.DBS_UPDATE_DATE
                  FROM M_AITESAKI
                  INNER JOIN
                        W_AITESAKI
                     ON W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_AITESAKI.AITE_CD   = M_AITESAKI.AITE_CD
      END

    --削除処理
    ELSE
      BEGIN

        --既存データ削除
        DELETE
          FROM M_AITESAKI
         WHERE M_AITESAKI.AITE_CD IN ( SELECT W_AITESAKI.AITE_CD
                                       FROM W_AITESAKI
                                      WHERE W_AITESAKI.W_USER_ID = @USER_ID
                                        AND W_AITESAKI.W_SERIAL  = @SERIAL
                                      GROUP BY
                                            W_AITESAKI.AITE_CD )
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_AITESAKI
     WHERE W_AITESAKI.W_USER_ID = @USER_ID
       AND W_AITESAKI.W_SERIAL  = @SERIAL

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
      FROM W_AITESAKI
     WHERE W_AITESAKI.W_USER_ID = @USER_ID
       AND W_AITESAKI.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
