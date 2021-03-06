/**
 * Copyright 2005-2007 Xue Yong Zhi
 * Distributed under the Apache License
 */

package com.xruby.compiler.codedom;

public class BodyStatementTest extends TestingAstTestCase {
    public void test() {
        String program_text =
                "begin\n" +
                "	raise \"!!!!\"\n" +
                "rescue RuntimeError\n" +
                "	print \"xxx\"\n" +
                "end";

        String expected_result =
            "body begin\n" +
            "self\n" +
            "!!!!\n" +
            "raise:false\n" +
            "body after\n" +
            "visitPrepareEnsure\n" +
            "visitRescueBegin\n" +
            "[:1:1:false\n" +
            "RuntimeError\n" +
            "]!\n" +
            "=>null\n" +
            "self\n" +
            "xxx\n" +
            "print:false\n" +
            "nil\n" +
            "$! =\n" +
            ";\n" +
            "end rescue\n" +
            "end rescue!\n" +
            "body end\n" +
            "EOF";
        assertAstOutput(program_text, expected_result);
    }

    public void test2() {
        String program_text =
                "begin\n" +
                "	raise \"!!!!\"\n" +
                "	rescue M::RuntimeError => e\n" +
                "		print e\n" +
                "end";

        String expected_result =
            //TODO seems e is not handled correctly
            "body begin\n" +
            "self\n" +
            "!!!!\n" +
            "raise:false\n" +
            "body after\n" +
            "visitPrepareEnsure\n" +
            "visitRescueBegin\n" +
            "[:1:1:false\n" +
            "M\n" +
            "::RuntimeError\n" +
            "]!\n" +
            "=>e\n" +
            "self\n" +
            "e\n" +
            "print:false\n" +
            "nil\n" +
            "$! =\n" +
            ";\n" +
            "end rescue\n" +
            "end rescue!\n" +
            "body end\n" +
            "EOF";
        assertAstOutput(program_text, expected_result);
    }
}
