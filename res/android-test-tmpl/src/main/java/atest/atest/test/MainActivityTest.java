package <%= package_name %>.test;

import android.test.ActivityInstrumentationTestCase2;
import <%= package_name %>.*;

public class MainActivityTest extends ActivityInstrumentationTestCase2<MainActivity_> {

    public MainActivityTest() {
        super(MainActivity_.class); 
    }

    public void testActivity() {
        MainActivity activity = getActivity();
        assertNotNull(activity);
    }
}

