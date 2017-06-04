package eta.runtime.apply;

import eta.runtime.stg.StgClosure;
import eta.runtime.stg.StgContext;
import eta.runtime.stg.StackFrame;

public class ApD extends StackFrame {
    public double d;

    public ApD(double d) {
        this.d = d;
    }

    @Override
    public void stackEnter(StgContext context) {
        context.R(1).applyD(context, d);
    }
}
