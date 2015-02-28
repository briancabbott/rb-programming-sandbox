/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package org.yecht;

import java.util.Map;
import java.util.HashMap;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Parser {
    private Parser() {}

    public Object root, root_on_error;
    boolean implicit_typing, taguri_expansion;
    NodeHandler handler;
    ErrorHandler error_handler;
    BadAnchorHandler bad_anchor_handler = new BadAnchorHandler.Default();
    ParserInput input_type;
    IOType io_type;
    public int bufsize;
    public Pointer buffer;
    public int linectptr, lineptr, token, toktmp, cursor = -1, marker, limit;
    public int linect;
    int last_token;
    int force_token;
    public boolean eof;
    JechtIO io;
    Map<String, Node> anchors, bad_anchors, prepared_anchors;
//     Map<Integer, Object> syms;
    Level[] levels;
    int lvl_idx;
    int lvl_capa;
    public Object bonus;

    // syck_parser_reset_levels
    public void resetLevels() {
        while(lvl_idx > 1) {
            popLevel();
        }

        if(lvl_idx < 1) {
            lvl_idx = 1;
            levels[0] = new Level();
            levels[0].spaces = -1;
            levels[0].ncount = 0;
            levels[0].domain = "";
        }
        levels[0].status = LevelStatus.header;
    }

    // syck_parser_pop_level
    public void popLevel() {
        if(lvl_idx <= 1) {
            return;
        }
        lvl_idx--;
    }

    // syck_parser_reset_cursor
    public void resetCursor() {
        if(buffer == null) {
            buffer = Pointer.create(new byte[bufsize], 0);
        }
        buffer.buffer[buffer.start] = 0;
        cursor = -1;
        lineptr = -1;
        linectptr = -1;
        token = -1;
        toktmp = -1;
        marker = -1;
        limit = -1;

        root = null;
        root_on_error = null;
        linect = 0;
        eof = false;
        last_token = 0;
        force_token = 0;
    }

    // syck_parser_set_root_on_error
    public void setRootOnError(Object roer) {
        this.root_on_error = roer;
    }

    // syck_new_parser
    public static Parser newParser() {
        Parser p = new Parser();
        p.lvl_capa = YAML.ALLOC_CT;
        p.levels = new Level[p.lvl_capa];
        p.input_type = ParserInput.YAML_UTF8;
        p.io_type = IOType.Str;
        p.io = null;
//         p.syms = new HashMap<Integer, Object>();
        p.anchors = null;
        p.bad_anchors = null;
        p.prepared_anchors = null;
        p.implicit_typing = true;
        p.taguri_expansion = false;
        p.bufsize = YAML.BUFFERSIZE;
        p.buffer = null;
        p.lvl_idx = 0;
        p.resetLevels();
        return p;
    }

//     // syck_add_sym
//     public int addSym(Object data) {
//         int id = syms.size() + 1;
//         syms.put(Integer.valueOf(id), data);
//         return id;
//     }

//     // syck_lookup_sym
//     public Object lookupSym(long id) {
//         return syms.get(Integer.valueOf((int)id));
//     }

    // syck_parser_handler
    public void handler(NodeHandler hdlr) {
        handler = hdlr;
    }

    // syck_parser_implicit_typing
    public void implicitTyping(boolean flag) {
        implicit_typing = flag;
    }

    // syck_parser_taguri_expansion
    public void taguriExpansion(boolean flag) {
        taguri_expansion = flag;
    }
    
    // syck_parser_error_handler
    public void errorHandler(ErrorHandler hdlr) {
        error_handler = hdlr;
    }

    // syck_parser_bad_anchor_handler
    public void badAnchorHandler(BadAnchorHandler hdlr) {
        bad_anchor_handler = hdlr;
    }

    // syck_parser_set_input_type
    public void setInputType(ParserInput input_type) {
        this.input_type = input_type;
    }

    // syck_parser_file
    public void file(java.io.InputStream fp, IoFileRead read) {
        resetCursor();
        io_type = IOType.File;
        if(read == null) {
            read = new IoFileRead.Default();
        }

        io = new JechtIO.File(fp, read);
    }

    // syck_parser_str
    public void str(Pointer ptr, int len, IoStrRead read) {
        resetCursor();
        io_type = IOType.Str;
        JechtIO.Str ss = new JechtIO.Str();
        io = ss;
        ss.beg = ptr.start;
        ss.ptr = ptr;
        ss.end = ptr.start + len;
        if(read == null) {
            ss.read = new IoStrRead.Default();
        } else {
            ss.read = read;
        }
    }

    // syck_parser_str_auto
    public void str(Pointer ptr, IoStrRead read) {
        str(ptr, ptr.buffer.length - ptr.start, read);
    }

    // syck_parser_current_level
    public Level currentLevel() {
        return levels[lvl_idx-1];
    }
    
    // syck_parser_add_level
    public void addLevel(int len, LevelStatus status) {
        if(lvl_idx + 1 > lvl_capa) {
            lvl_capa += YAML.ALLOC_CT;
            levels = YAML.realloc(levels, lvl_capa);
        }
        levels[lvl_idx] = new Level();
        levels[lvl_idx].spaces = len;
        levels[lvl_idx].ncount = 0;
        levels[lvl_idx].domain = levels[lvl_idx-1].domain;
        levels[lvl_idx].status = status;
        lvl_idx++;
    }

    // syck_move_tokens
    public int moveTokens() {
        int count;
        if(token == -1) {
            return 0;
        }

        int skip = limit - token;
        if(skip < 0) {
            return 0;
        }

        if((count = token - buffer.start) != 0) {
            System.arraycopy(buffer.buffer, token, buffer.buffer, buffer.start, skip);
            token = buffer.start;
            marker -= count;
            cursor -= count;
            toktmp -= count;
            limit -= count;
            lineptr -= count;
            linectptr -= count;
        }
        return skip;
    }

    // syck_check_limit
    public void checkLimit(int len) {
        if(cursor == -1) {
            cursor = buffer.start;
            lineptr = buffer.start;
            linectptr = buffer.start;
            marker = buffer.start;
        }
        limit = buffer.start + len;
    }

    // syck_parser_read
    public int read() throws java.io.IOException {
        int len = 0;
        int skip = 0;
        
        switch(io_type) {
        case Str:
            skip = moveTokens();
            len = ((JechtIO.Str)io).read.read(buffer, ((JechtIO.Str)io), YAML.BUFFERSIZE-1, skip);
            break;
        case File:
            skip = moveTokens();
            len = ((JechtIO.File)io).read.read(buffer, ((JechtIO.File)io), YAML.BUFFERSIZE-1, skip);
            break;
        default:
            break;
        }
        checkLimit(len);
        return len;
    }

    // syck_parser_readlen
    public int read(int max_size) throws java.io.IOException {
        int len = 0;
        int skip = 0;
        
        switch(io_type) {
        case Str:
            skip = moveTokens();
            len = ((JechtIO.Str)io).read.read(buffer, ((JechtIO.Str)io), max_size, skip);
            break;
        case File:
            skip = moveTokens();
            len = ((JechtIO.File)io).read.read(buffer, ((JechtIO.File)io), max_size, skip);
            break;
        default:
            break;
        }
        checkLimit(len);
        return len;
    }

    // syck_parse
    public Object parse() {
        resetLevels();
        yechtparse();
        return root;
    }

    private void yechtparse() {
        try {
            new DefaultYAMLParser(this).yyparse(TokenScanner.createScanner(this));
        } catch(java.io.IOException e) {
            root = root_on_error;
        }
    }

    // syck_hdlr_add_node
    public Object addNode(Node n) {
        //        System.err.println("addNode(" + n + ")");
        if(n.id == null) {
            n.id = handler.handle(this, n);
        }
        return n.id;
    }

//     public void prepareAnchor(String a, Node n) {
//         System.err.println("prepareAnchor(" + a + ", " + n + ")");
//         if(prepared_anchors == null) {
//             prepared_anchors = new HashMap<String, Node>();
//         }
//         prepared_anchors.put(a, n);
//     }

    // syck_hdlr_add_anchor
    public Node addAnchor(String a, Node n) {
//         System.err.println("addAnchor(" + a + ", " + n + ")");

        n.anchor = a;
        if(bad_anchors != null) {
//             System.err.print(" -- bad_anchors != null\n");
            if(bad_anchors.containsKey(a)) {
//                 System.err.print(" -- st_lookup(p->bad_anchors) succeeded\n");
                if(n.kind != KindTag.Str) {
                    Node bad = bad_anchors.get(a);
//                     System.err.print(" -- this is not a str\n");
//                     System.err.print(" -- id: " + n.id + ", bad.id: " + bad.id +"\n");
                    n.id = bad.id;
                    handler.handle(this, n);
                }
            }
        }
        if(anchors == null) {
//             System.err.print(" -- anchors == null\n");
            anchors = new HashMap<String, Node>();
        }
//         System.err.print(" -- inserting into the anchor again\n");
        anchors.put(a, n);
        return n;
    }

    // syck_hdlr_remove_anchor
    public void removeAnchor(String a) {
        if(anchors == null) {
            anchors = new HashMap<String, Node>();
        }
        anchors.put(a, null);
    }

    // syck_hdlr_get_anchor
    public Node getAnchor(String a) {
//         System.err.println("getAnchor(" + a + ")");
        Node n = null;
        if(anchors != null) {
//             System.err.print(" -- anchors != null\n");
            if(anchors.containsKey(a)) {
//                 System.err.print(" -- st_lookup succeeded\n");
                n = anchors.get(a);
                if(n != null) {
//                     System.err.print(" -- n != 1\n");
                    return n;
                } else {
//                     System.err.print(" -- n === 1\n");
                    if(bad_anchors == null) {
//                         System.err.print(" -- creating new list of bad anchors\n");
                        bad_anchors = new HashMap<String, Node>();
                    }
//                     System.err.print(" -- checking if n exists in bad anchors\n");
                    if(!bad_anchors.containsKey(a)) {
//                         System.err.print(" -- no, it doesnt\n");
                        n = bad_anchor_handler.handle(this, a);
                        bad_anchors.put(a, n);
                    } else {
                        n = bad_anchors.get(a);
                    }
                }
            }
        }

//         System.err.print(" -- n == null?\n");
        if(n == null) {
//             System.err.print(" --- yep ?\n");
            n = bad_anchor_handler.handle(this, a);
        }

        if(n.anchor == null) {
            n.anchor = a;
        }

        return n;
    }

    // syck_add_transfer
    public static void addTransfer(String uri, Node n, boolean taguri) {
        if(!taguri) {
            n.type_id = uri;
            return;
        }
        n.type_id = ImplicitScanner.typeIdToUri(uri);
    }

    // syck_xprivate
    public static String xprivate(String type_id) {
        return "x-private:" + type_id;
    }

    // syck_taguri
    public static String taguri(String domain, String type_id) {
        return "tag:" + domain + ":" + type_id;
    }

    // syck_try_implicit
    public static boolean tryImplicit(Node n) {
        return true;
    }
}// Parser
