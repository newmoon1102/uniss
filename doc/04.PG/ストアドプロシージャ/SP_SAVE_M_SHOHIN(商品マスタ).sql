--DROP PROCEDURE SP_SAVE_M_SHOHIN

CREATE PROCEDURE SP_SAVE_M_SHOHIN
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
AS
--保存処理実行
BEGIN

--変数定義

    --戻り値
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
               M_SHOHIN( SHOHIN_CD
                        ,SHOHIN_MEI
                        ,AITE_SHOHIN_MEI
                        ,HIMBAN
                        ,SHIYAKU_MEI
                        ,SHIYAKU_NAIYO
                        ,DOKU_MEISHO
                        ,DOKU_SURYO
                        ,BUNSEKI_FLG
                        ,SHOHIN_FLG
                        ,KOBAIHIN_FLG
                        ,SHOKEIHI_FLG
                        ,SHOHIN_STS
                        ,SHOHIN_BUNRUI
                        ,CHOSEI_SHIYAKU_FLG
                        ,DOKU_FLG
                        ,SHIYAKU_FLG
                        ,SHIIRE_CD
                        ,MAKER_CD
                        ,GAICHU_CD
                        ,IRISU
                        ,IRISU_TANI
                        ,BARA_TANI
                        ,HYOJUN_KAKAKU
                        ,GENKA
                        ,BAIKA
                        ,SHIIRE_TANKA
                        ,SHIIRE_IRISU
                        ,SHIIRE_IRISU_TANI
                        ,HYOJUN_NOKI
                        ,HYOJUN_KOSU
                        ,TEIKA
                        ,SAITEI_KAKAKU
                        ,SHIJO_KAKAKU
                        ,HOKANBASHO_KBN
                        ,SHIKIICHI
                        ,BUNSEKI_TANI
                        ,BUNSEKI_NO
                        ,BUNSEKI_FLOW
                        ,BIKO
                        ,LINK_DATETIME
                        ,MISHIYO_FLG
                        ,DBS_STATUS
                        ,DBS_CREATE_USER
                        ,DBS_CREATE_DATE
                        ,DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE
                      )
                 SELECT W_SHOHIN.SHOHIN_CD
                       ,W_SHOHIN.SHOHIN_MEI
                       ,W_SHOHIN.AITE_SHOHIN_MEI
                       ,W_SHOHIN.HIMBAN
                       ,W_SHOHIN.SHIYAKU_MEI
                       ,W_SHOHIN.SHIYAKU_NAIYO
                       ,W_SHOHIN.DOKU_MEISHO
                       ,W_SHOHIN.DOKU_SURYO
                       ,W_SHOHIN.BUNSEKI_FLG
                       ,W_SHOHIN.SHOHIN_FLG
                       ,W_SHOHIN.KOBAIHIN_FLG
                       ,W_SHOHIN.SHOKEIHI_FLG
                       ,W_SHOHIN.SHOHIN_STS
                       ,W_SHOHIN.SHOHIN_BUNRUI
                       ,W_SHOHIN.CHOSEI_SHIYAKU_FLG
                       ,W_SHOHIN.DOKU_FLG
                       ,W_SHOHIN.SHIYAKU_FLG
                       ,W_SHOHIN.SHIIRE_CD
                       ,W_SHOHIN.MAKER_CD
                       ,W_SHOHIN.GAICHU_CD
                       ,W_SHOHIN.IRISU
                       ,W_SHOHIN.IRISU_TANI
                       ,W_SHOHIN.BARA_TANI
                       ,W_SHOHIN.HYOJUN_KAKAKU
                       ,W_SHOHIN.GENKA
                       ,W_SHOHIN.BAIKA
                       ,W_SHOHIN.SHIIRE_TANKA
                       ,W_SHOHIN.SHIIRE_IRISU
                       ,W_SHOHIN.SHIIRE_IRISU_TANI
                       ,W_SHOHIN.HYOJUN_NOKI
                       ,W_SHOHIN.HYOJUN_KOSU
                       ,W_SHOHIN.TEIKA
                       ,W_SHOHIN.SAITEI_KAKAKU
                       ,W_SHOHIN.SHIJO_KAKAKU
                       ,W_SHOHIN.HOKANBASHO_KBN
                       ,W_SHOHIN.SHIKIICHI
                       ,W_SHOHIN.BUNSEKI_TANI
                       ,W_SHOHIN.BUNSEKI_NO
                       ,W_SHOHIN.BUNSEKI_FLOW
                       ,W_SHOHIN.BIKO
                       ,W_SHOHIN.LINK_DATETIME
                       ,W_SHOHIN.MISHIYO_FLG
                       ,W_SHOHIN.DBS_STATUS
                       ,W_SHOHIN.DBS_CREATE_USER
                       ,W_SHOHIN.DBS_CREATE_DATE
                       ,W_SHOHIN.DBS_UPDATE_USER
                       ,W_SHOHIN.DBS_UPDATE_DATE
                   FROM W_SHOHIN
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL


--インフォメーション生成処理
--購買品の登録があった場合、購買品登録通知を生成する
    IF ( SELECT W_SHOHIN.KOBAIHIN_FLG
           FROM W_SHOHIN
          WHERE W_USER_ID = @USER_ID
            AND W_SERIAL  = @SERIAL
            AND W_ROW     = 1 ) = 'True'
    BEGIN

        EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,5

    END

END
--------------------------------------------------------------------

    --更新処理
    ELSE IF @MODE = 2
        BEGIN
            UPDATE M_SHOHIN
                SET
                         SHOHIN_CD                         =  W_SHOHIN.SHOHIN_CD
                        ,SHOHIN_MEI                        =  W_SHOHIN.SHOHIN_MEI
                        ,AITE_SHOHIN_MEI                   =  W_SHOHIN.AITE_SHOHIN_MEI
                        ,HIMBAN                            =  W_SHOHIN.HIMBAN
                        ,SHIYAKU_MEI                       =  W_SHOHIN.SHIYAKU_MEI
                        ,SHIYAKU_NAIYO                     =  W_SHOHIN.SHIYAKU_NAIYO
                        ,DOKU_MEISHO                       =  W_SHOHIN.DOKU_MEISHO
                        ,DOKU_SURYO                        =  W_SHOHIN.DOKU_SURYO
                        ,BUNSEKI_FLG                       =  W_SHOHIN.BUNSEKI_FLG
                        ,SHOHIN_FLG                        =  W_SHOHIN.SHOHIN_FLG
                        ,KOBAIHIN_FLG                      =  W_SHOHIN.KOBAIHIN_FLG
                        ,SHOKEIHI_FLG                      =  W_SHOHIN.SHOKEIHI_FLG
                        ,SHOHIN_STS                        =  W_SHOHIN.SHOHIN_STS
                        ,SHOHIN_BUNRUI                     =  W_SHOHIN.SHOHIN_BUNRUI
                        ,CHOSEI_SHIYAKU_FLG                =  W_SHOHIN.CHOSEI_SHIYAKU_FLG
                        ,DOKU_FLG                          =  W_SHOHIN.DOKU_FLG
                        ,SHIYAKU_FLG                       =  W_SHOHIN.SHIYAKU_FLG
                        ,SHIIRE_CD                         =  W_SHOHIN.SHIIRE_CD
                        ,MAKER_CD                          =  W_SHOHIN.MAKER_CD
                        ,GAICHU_CD                         =  W_SHOHIN.GAICHU_CD
                        ,IRISU                             =  W_SHOHIN.IRISU
                        ,IRISU_TANI                        =  W_SHOHIN.IRISU_TANI
                        ,BARA_TANI                         =  W_SHOHIN.BARA_TANI
                        ,HYOJUN_KAKAKU                     =  W_SHOHIN.HYOJUN_KAKAKU
                        ,GENKA                             =  W_SHOHIN.GENKA
                        ,BAIKA                             =  W_SHOHIN.BAIKA
                        ,SHIIRE_TANKA                      =  W_SHOHIN.SHIIRE_TANKA
                        ,SHIIRE_IRISU                      =  W_SHOHIN.SHIIRE_IRISU
                        ,SHIIRE_IRISU_TANI                 =  W_SHOHIN.SHIIRE_IRISU_TANI
                        ,HYOJUN_NOKI                       =  W_SHOHIN.HYOJUN_NOKI
                        ,HYOJUN_KOSU                       =  W_SHOHIN.HYOJUN_KOSU
                        ,TEIKA                             =  W_SHOHIN.TEIKA
                        ,SAITEI_KAKAKU                     =  W_SHOHIN.SAITEI_KAKAKU
                        ,SHIJO_KAKAKU                      =  W_SHOHIN.SHIJO_KAKAKU
                        ,HOKANBASHO_KBN                    =  W_SHOHIN.HOKANBASHO_KBN
                        ,SHIKIICHI                         =  W_SHOHIN.SHIKIICHI
                        ,BUNSEKI_TANI                      =  W_SHOHIN.BUNSEKI_TANI
                        ,BUNSEKI_NO                        =  W_SHOHIN.BUNSEKI_NO
                        ,BUNSEKI_FLOW                      =  W_SHOHIN.BUNSEKI_FLOW
                        ,BIKO                              =  W_SHOHIN.BIKO
                        ,LINK_DATETIME                     =  W_SHOHIN.LINK_DATETIME
                        ,MISHIYO_FLG                       =  W_SHOHIN.MISHIYO_FLG
                        ,DBS_STATUS                        =  W_SHOHIN.DBS_STATUS
            --            ,DBS_CREATE_USER                   =  W_SHOHIN.DBS_CREATE_USER
            --            ,DBS_CREATE_DATE                   =  W_SHOHIN.DBS_CREATE_DATE
                        ,DBS_UPDATE_USER                   =  W_SHOHIN.DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE                   =  W_SHOHIN.DBS_UPDATE_DATE
                  FROM M_SHOHIN
                 INNER JOIN
                        W_SHOHIN
                     ON W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_SHOHIN.SHOHIN_CD  = M_SHOHIN.SHOHIN_CD
      END


    --削除処理
    ELSE
      BEGIN

        DELETE
          FROM M_SHOHIN
         WHERE M_SHOHIN.SHOHIN_CD IN ( SELECT W_SHOHIN.SHOHIN_CD
                                         FROM W_SHOHIN
                                        WHERE W_SHOHIN.W_USER_ID = @USER_ID
                                          AND W_SHOHIN.W_SERIAL  = @SERIAL
                                      GROUP BY
                                              W_SHOHIN.SHOHIN_CD )

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_SHOHIN
     WHERE W_SHOHIN.W_USER_ID = @USER_ID
       AND W_SHOHIN.W_SERIAL  = @SERIAL

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
      FROM W_SHOHIN
     WHERE W_SHOHIN.W_USER_ID = @USER_ID
       AND W_SHOHIN.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
