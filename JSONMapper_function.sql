

/****** Object:  UserDefinedFunction [EDE].[JSONOBJMapper_V2]    Script Date: 8/25/2021 7:07:09 PM ******/
SET ansi_nulls ON

go

SET quoted_identifier ON

go

CREATE FUNCTION [dbo].[JsonMapper] (     @JSON VARCHAR(max),
                                         @Path    VARCHAR(max),
                                         @SetValue   VARCHAR(max),
                                         @type    VARCHAR(max)
										 )

returns VARCHAR(max)
AS
  BEGIN


      SET @Path=Replace(@Path, '$.', '');
      SET @Path=Replace(@Path, '"', '');
      SET @SetValue=Cast(@SetValue AS VARCHAR(max))

      DECLARE @delimiter NVARCHAR(1);
      DECLARE @out_put VARCHAR(max);

      SET @delimiter = '.';

      BEGIN
          DECLARE @SetValue_SMLL NVARCHAR(max),
                  @pos        INT= 0,
                  @len        INT= 0;

          SET @Path = CASE
                        WHEN RIGHT(@Path, 1) != @delimiter THEN @Path +
                        @delimiter
                        ELSE @Path
                      END;

          DECLARE @Flag INT;

          SET @Flag = 0;

          WHILE Charindex(@delimiter, @Path, @pos + 1) > 0
            BEGIN
                SET @len = Charindex(@delimiter, @Path, @pos + 1) - @pos;
                SET @SetValue_SMLL = Substring(@Path, @pos, @len);

                IF( @Flag > 0 )
                  BEGIN
                      SET @out_put = @out_put + '."' + Ltrim(Rtrim(@SetValue_SMLL))
                                     +
                                     '"'
                      ;
                  END;
                ELSE
                  BEGIN
                      SET @out_put = '"' + Ltrim(Rtrim(@SetValue_SMLL)) + '"';
                  END;

                IF NOT EXISTS(SELECT *
                              FROM   Openjson(@JSON, '$.' + @out_put))
                  BEGIN
                      DECLARE @EMPTY VARCHAR(max);

                      SET @EMPTY='{}'
                      SET @JSON=Json_modify(@JSON, '$.' + @out_put,
                                   Json_query('{}')
                                   );
                  END

                SET @Flag = @Flag + 1;
                SET @pos = Charindex(@delimiter, @Path, @pos+@len) + 1;

                IF( Len(@Path) + 1 = @pos )
                  BEGIN
                      IF( @SetValue IS NULL
                           OR @SetValue = 'null' )
                        BEGIN
                            SET @JSON=Json_modify(@JSON, '$.' + @out_put,
                                         'null'
                                         )
                        END
                      ELSE IF( @SetValue LIKE '%{%'
                          AND @SetValue LIKE '%}%' )
                        BEGIN
                            SET @JSON=Json_modify(@JSON, '$.' + @out_put,
                                         Json_query(@SetValue)
                                         )
                        END
                      ELSE
                        BEGIN
                            IF( ( @SetValue = '1' )
                                 OR ( @SetValue = 'true' ) )
                              AND @type LIKE '%boolean%'
                              BEGIN
                                  SET @JSON=Json_modify(@JSON, '$.' +
                                               @out_put,
                                               Cast(1 AS BIT))
                              END
                            ELSE IF( @SetValue = '0' )
                               OR ( @SetValue = 'false' )
                                  AND @type LIKE '%boolean%'
                              BEGIN
                                  SET @JSON=Json_modify(@JSON, '$.' +
                                               @out_put,
                                               Cast(0 AS BIT))
                              END
                            ELSE IF ( Isnumeric(@SetValue) = 1 )
                               AND @type LIKE '%numeric%'
                              BEGIN
                                  IF( Isnumeric(Replace(Replace(@SetValue, '+', 'A'
                                                ),
                                                '-'
                                                ,
                                                'A')
                                                + '.0e0') = 1 )
                                    BEGIN
                                        SET @JSON=Json_modify(@JSON, '$.'
                                                     +
                                                     @out_put
                                                     ,
                                                     Cast
                                                     (
                                                     ( @SetValue ) AS BIGINT))
                                    END
                                  ELSE
                                    BEGIN
                                        SET @JSON=Json_modify(@JSON, '$.'
                                                     +
                                                     @out_put
                                                     ,
                                                     Cast
                                                     (
                                                     ( @SetValue ) AS
                                                     DECIMAL(18, 2))
                                                     )
                                    END
                              END
                            ELSE IF( @SetValue = '[]' )
                              AND @type LIKE '%array%'
                              BEGIN
                                  SET @JSON=Json_modify(@JSON, '$.' +
                                               @out_put,
                                               Json_query('[]')
                                               )
                              END
                            ELSE IF @type IS NULL
                                OR @type LIKE '%string%'
                              BEGIN
                                  SET @JSON=Json_modify(@JSON, '$.' +
                                               @out_put,
                                               (
                                               @SetValue )
                                               )
                              END
                            ELSE IF @type IS NULL
                                OR @type LIKE '%object%'
                              BEGIN
                                  SET @JSON=Json_modify(@JSON, '$.' +
                                               @out_put,
                                               Json_query(@SetValue)
                                               )
                              END
                        END
                  END
            --PRINT @pos
            END;
      END

      SET @JSON=Replace(@JSON, '"null"', 'null')

      RETURN @JSON;
  END  