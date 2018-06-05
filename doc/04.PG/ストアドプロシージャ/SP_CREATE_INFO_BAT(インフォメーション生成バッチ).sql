
--DROP PROCEDURE SP_CREATE_INFO_BAT

CREATE PROCEDURE SP_CREATE_INFO_BAT
       @INFO_ID  INT

AS
--インフォメーション生成バッチ処理実行
--[モード] 0:インフォメーションデータ削除 / 1:中間報告生成 / 2:速報生成

BEGIN

--変数定義

    --カーソル生成(通知先)
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

    --通知者
    DECLARE @NT_TANTO_CD NVARCHAR(10)
    --入力者通知フラグ
    DECLARE @FLG NVARCHAR(5)

--処理

    --入力者通知フラグ取得
    SET @FLG = ( SELECT M_INFO_H.NYURYOKUSHA_FLG 
                  FROM M_INFO_H
                 WHERE M_INFO_H.INFO_ID = @INFO_ID )

    --インフォメーションデータ削除
    IF @INFO_ID = 0
      BEGIN

        --１年以上経過した既読データ削除
        DELETE
          FROM T_INFO_R
         WHERE INFO_DATE_TIME <= DATEADD(MM,-12,getDate())

        --物理削除ユーザーのデータ削除
        DELETE
          FROM T_INFO
         WHERE NOT EXISTS
               ( SELECT *
                   FROM M_SHAIN
                  WHERE M_SHAIN.SHAIN_CD = T_INFO.NT_TANTO_CD )

        --物理削除ユーザーの既読データ削除
        DELETE
          FROM T_INFO_R
         WHERE NOT EXISTS
               ( SELECT *
                   FROM M_SHAIN
                  WHERE M_SHAIN.SHAIN_CD = T_INFO_R.NT_TANTO_CD )

      END

    --中間報告
    ELSE IF @INFO_ID = 1
      BEGIN
        --カーソルオープン
        OPEN TANTO_CURSOR

        FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN
            --インフォメーション生成
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
                  ,CONCAT( '="中間報告期限が過ぎています。"&CHAR(10)&"受理No.：'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,@NT_TANTO_CD
              FROM T_BUN_JUCHU_H
             --中間報告日１ <= 今日
             --分析ステータス < 中間報告済
             WHERE CHUKAN_DATE_1  <= CONVERT(CHAR,getDate(),111)
               AND CHUKAN_DATE_1  <> ''
               AND BUNSEKI_STS    IN ( '1','2' )
               AND NYURYOKUSHA_CD <> @NT_TANTO_CD
               AND DEL_FLG        = 'False'

             FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        END

        CLOSE TANTO_CURSOR

        --入力者通知
        IF @FLG = 'True'
          BEGIN
            --インフォメーション生成(入力者)
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
                  ,CONCAT( '="中間報告期限が過ぎています。"&CHAR(10)&"受理No.：'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
              FROM T_BUN_JUCHU_H
             --中間報告日１ <= 今日
             --分析ステータス < 中間報告済
             WHERE CHUKAN_DATE_1 <= CONVERT(CHAR,getDate(),111)
               AND CHUKAN_DATE_1 <> ''
               AND BUNSEKI_STS   IN ( '1','2' )
               AND DEL_FLG       =  'False'

          END

      END

    --速報
    ELSE IF @INFO_ID = 2
      BEGIN
        --カーソルオープン
        OPEN TANTO_CURSOR

        FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN
            --インフォメーション生成
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
                  ,CONCAT( '="速報期限が過ぎています。"&CHAR(10)&"受理No.：'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,@NT_TANTO_CD
              FROM T_BUN_JUCHU_H
             --報告書完成/速報日 <= 今日
             --分析ステータス < 速報済
             --速報区分 <> 不要
             WHERE KANSEI_DATE    <= CONVERT(CHAR,getDate(),111)
               AND BUNSEKI_STS    IN ( '1','2','3','4','5' )
               AND SOKUHO_KBN     <> '1'
               AND NYURYOKUSHA_CD <> @NT_TANTO_CD
               AND DEL_FLG        =  'False'

             FETCH NEXT FROM TANTO_CURSOR INTO @NT_TANTO_CD
        END

        CLOSE TANTO_CURSOR

        --入力者通知
        IF @FLG = 'True'
          BEGIN
            --インフォメーション生成(入力者)
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
                  ,CONCAT( '="速報期限が過ぎています。"&CHAR(10)&"受理No.：'
                                     ,T_BUN_JUCHU_H.JURI_NO
                                     ,'"' )
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
                  ,CONVERT(CHAR,getDate(),120)
                  ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
              FROM T_BUN_JUCHU_H
             --報告書完成/速報日 <= 今日
             --分析ステータス < 速報済
             --速報区分 <> 不要
             WHERE KANSEI_DATE <= CONVERT(CHAR,getDate(),111)
               AND BUNSEKI_STS IN ( '1','2','3','4','5' )
               AND SOKUHO_KBN  <> '1'
               AND DEL_FLG     =  'False'

          END

      END

    DEALLOCATE TANTO_CURSOR

END

