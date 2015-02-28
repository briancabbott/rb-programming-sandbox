/*
 * The MIT License
 *
 * Copyright 2014 kares.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.jruby.rack.mock.fail;

import java.io.IOException;
import org.jruby.rack.mock.MockHttpServletResponse;

/**
 * @author kares
 */
public class FailingHttpServletResponse extends MockHttpServletResponse {

    private FailingServletOutputStream outputStream;

    @Override
    public FailingServletOutputStream getOutputStream() {
        if (outputStream == null) {
            outputStream = new FailingServletOutputStream(new IOException("Broken pipe"));
        }
        return outputStream;
    }

    public void setOutputStream(FailingServletOutputStream outputStream) {
        this.outputStream = outputStream;
    }

    public void setFailure(IOException failure) {
        getOutputStream().setFailure(failure);
    }

}
