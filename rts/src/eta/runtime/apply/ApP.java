package eta.runtime.apply;

import eta.runtime.stg.StgClosure;
import eta.runtime.stg.StgContext;
import eta.runtime.stg.StackFrame;

public class ApP extends StackFrame {
    public StgClosure p;

    public ApP(StgClosure p) {
        this.p = p;
    }

    @Override
    public void stackEnter(StgContext context) {
        context.R(1).applyP(context, p);
    }
}
