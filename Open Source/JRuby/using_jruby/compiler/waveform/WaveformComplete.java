import org.jruby.embed.ScriptingContainer;

public class WaveformComplete {
    static ScriptingContainer rubyContainer;
    Object waveform;

    // START:static
    static {
        String source = new StringBuilder(
            "class Waveform\n" +
            "  def initialize(points)\n" +
            "    @points = points\n" +
            "  end\n" +
            "\n" +
            "  def rms\n" +
            "    raise 'No points' unless @points.length > 0\n" +
            "    squares = @points.map {|p| p * p}\n" +
            "    sum     = squares.inject {|s, p| s + p}\n" +
            "    mean    = sum / squares.length\n" +
            "    Math.sqrt(mean)\n" +
            "  end\n" +
            "end\n").toString();

        rubyContainer = new ScriptingContainer();
        rubyContainer.runScriptlet(source);
    }
    // END:static

    public WaveformComplete(double[] points) {
        Object waveformClass = rubyContainer.runScriptlet("Waveform");
        waveform = rubyContainer.callMethod(waveformClass, "new", points);
    }

    public double rms() {
        return (Double)rubyContainer.callMethod(waveform, "rms");
    }
}
