package <%= package_name %>.test;

import android.test.ActivityInstrumentationTestCase2;
import com.robotium.solo.Solo;
import <%= package_name %>.*;

public class MainActivityTest extends ActivityInstrumentationTestCase2<MainActivity_> {

    private Solo solo;

    @Override
    public void setUp() throws Exception {
        //setUp() is run before a test case is started. 
        //This is where the solo object is created.
        solo = new Solo(getInstrumentation(), getActivity());
    }

    @Override
    public void tearDown() throws Exception {
        //tearDown() is run after a test case has finished. 
        //finishOpenedActivities() will finish all the activities that have been opened during the test execution.
        solo.finishOpenedActivities();
    }


    public MainActivityTest() {
        super(MainActivity_.class); 
    }

    public void testActivity() {
        MainActivity activity = getActivity();
        assertNotNull(activity);
    }
}

