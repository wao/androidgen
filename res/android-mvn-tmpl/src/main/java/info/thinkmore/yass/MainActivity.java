package <%= package_name %>;

import android.app.Activity;
import android.view.Menu;
import <%= androidannotations_groupid %>.annotations.*;

@EActivity(R.layout.activity_main)
public class MainActivity
    extends Activity
{

    @AfterViews
    void afterViews() {
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater();
        return true;
    }

}
