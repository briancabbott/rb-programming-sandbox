/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package org.jcodings.specific;

import org.jcodings.Config;
import org.jcodings.IntHolder;
import org.jcodings.ascii.AsciiTables;
import org.jcodings.unicode.UnicodeEncoding;

public final class UTF16BEEncoding extends UnicodeEncoding {

    protected UTF16BEEncoding() {
        super("UTF-16BE", 2, 4, UTF16EncLen);
    }

    @Override
    public int length(byte[]bytes, int p, int end) {
        if (Config.VANILLA) {
            return length(bytes[p]);
        } else {
            int b = bytes[p] & 0xff;
            if (!isSurrogate(b)) {
                return end - p >= 2 ? 2 : missing(1);
            }
            if (isSurrogateFirst(b)) {
                switch (end - p) {
                case 1:     return missing(3);
                case 2:     return missing(2);
                case 3:     if (isSurrogateSecond(bytes[p + 2] & 0xff)) return missing(1);
                default:    if (isSurrogateSecond(bytes[p + 2] & 0xff)) return 4;
                }
            }
        }
        return CHAR_INVALID;
    }

    @Override
    public boolean isNewLine(byte[]bytes, int p, int end) {
        if (p + 1 < end) {
            if (bytes[p + 1] == (byte)0x0a && bytes[p] == (byte)0x00) return true;

            if (Config.USE_UNICODE_ALL_LINE_TERMINATORS) {
                if ((!Config.USE_CRNL_AS_LINE_TERMINATOR && bytes[p+1] == (byte)0x0d) ||
                        bytes[p+1] == (byte)0x85 && bytes[p] == (byte)0x00) return true;

                if (bytes[p] == (byte)0x20 && (bytes[p+1] == (byte)0x29 || bytes[p+1] == (byte)0x28)) return true;
            }
        }
        return false;
    }

    @Override
    public int mbcToCode(byte[]bytes, int p, int end) {
        final int code;
        if (isSurrogateFirst(bytes[p] & 0xff)) {
            if (Config.VANILLA) {
                code = ((((bytes[p + 0] & 0xff - 0xd8) << 2) +
                        ((bytes[p + 1] & 0xff & 0xc0) >> 6) + 1) << 16) +
                      ((((bytes[p + 1] & 0xff & 0x3f) << 2) +
                         (bytes[p + 2] & 0xff - 0xdc)) << 8) +
                          bytes[p + 3] & 0xff;
            } else {
                code = (((((bytes[p + 0] & 0xff) << 8) + (bytes[p + 1] & 0xff)) & 0x03ff) << 10) +
                        ((((bytes[p + 2] & 0xff) << 8) + (bytes[p + 3] & 0xff)) & 0x03ff) + 0x10000;
            }
        } else {
            code =  (bytes[p + 0] & 0xff) * 256 + (bytes[p + 1] & 0xff);
        }
        return code;
    }

    @Override
    public int codeToMbcLength(int code) {
        return code > 0xffff ? 4 : 2;
    }

    @Override
    public int codeToMbc(int code, byte[]bytes, int p) {
        int p_ = p;
        if (code > 0xffff) {
            if (Config.VANILLA) {
                int plane = (code >>> 16) - 1;
                bytes[p_++] = (byte)((plane >>> 2) + 0xd8);
                int high = (code & 0xff00) >>> 8;
                bytes[p_++] = (byte)(((plane & 0x03) << 6) + (high >>> 2));
                bytes[p_++] = (byte)((high & 0x03) + 0xdc);
                bytes[p_]   = (byte)(code & 0xff);
            } else {
                int high = (code >>> 10) + 0xd7c0;
                int low = (code & 0x3ff) + 0xdc00;
                bytes[p_++] = (byte)((high >>> 8) & 0xff);
                bytes[p_++] = (byte)(high & 0xff);
                bytes[p_++] = (byte)((low >>> 8) & 0xff);
                bytes[p_]   = (byte)(low & 0xff);
            }
            return 4;
        } else {
            bytes[p_++] = (byte)((code & 0xff00) >>> 8);
            bytes[p_++] = (byte)(code & 0xff);
            return 2;
        }
    }

    @Override
    public int mbcCaseFold(int flag, byte[]bytes, IntHolder pp, int end, byte[]fold) {
        int p = pp.value;
        int foldP = 0;

        if (isAscii(bytes[p+1] & 0xff) && bytes[p] == 0) {
            p++;

            if (Config.USE_UNICODE_CASE_FOLD_TURKISH_AZERI) {
                if ((flag & Config.ENC_CASE_FOLD_TURKISH_AZERI) != 0) {
                    if (bytes[p] == (byte)0x49) {
                        fold[foldP++] = (byte)0x01;
                        fold[foldP] = (byte)0x31;
                        pp.value += 2;
                        return 2;
                    }
                }
            } // USE_UNICODE_CASE_FOLD_TURKISH_AZERI

            fold[foldP++] = 0;
            fold[foldP] = AsciiTables.ToLowerCaseTable[bytes[p] & 0xff];
            pp.value += 2;
            return 2;
        } else {
            return super.mbcCaseFold(flag, bytes, pp, end, fold);
        }
    }

    /** onigenc_utf16_32_get_ctype_code_range
     */
    @Override
    public int[]ctypeCodeRange(int ctype, IntHolder sbOut) {
        sbOut.value = 0x00;
        return super.ctypeCodeRange(ctype);
    }

    @Override
    public int leftAdjustCharHead(byte[]bytes, int p, int s, int end) {
        if (s <= p) return s;

        if ((s - p) % 2 == 1) s--;

        if (isSurrogateSecond(bytes[s] & 0xff) && s > p + 1) s -= 2;

        return s;
    }

    @Override
    public boolean isReverseMatchAllowed(byte[]bytes, int p, int end) {
        return false;
    }

    static final int UTF16EncLen[] = {
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    };

    private static boolean isSurrogateFirst(int c) {
        if (Config.VANILLA) {
            return c >= 0xd8 && c <= 0xdb;
        } else {
            return (c & 0xfc) == 0xd8;
        }
    }

    private static boolean isSurrogateSecond(int c) {
        if (Config.VANILLA) {
            return c >= 0xdc && c <= 0xdf;
        } else {
            return (c & 0xfc) == 0xdc;
        }
    }

    private static boolean isSurrogate(int c) {
        if (Config.VANILLA) {
            return (c & 0xf8) == 0;
        } else {
            return (c & 0xf8) == 0xd8;
        }

    }

    public static final UTF16BEEncoding INSTANCE = new UTF16BEEncoding();
}
