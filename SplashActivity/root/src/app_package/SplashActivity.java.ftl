package  ${packageName}.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPropertyAnimatorCompat;
import android.view.View;
import android.view.animation.DecelerateInterpolator;
import android.widget.ImageView;
import ${packageName}.Activity.BaseActivity;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import ${packageName}.Present.SplashPresent;
import ${packageName}.Utils.ShareUtils;
import ${packageName}.View.SplashView;
import ${packageName}.R;

import java.util.concurrent.TimeUnit;
import javax.inject.Inject;

import rx.Observable;
import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;

public class ${activityClass} extends BaseActivity implements SplashView{
    private static final int STARTUP_DELAY = 300; // 启动延迟
    private static final int ANIM_ITEM_DURATION = 2000;

    private ImageView tempPage;
    private ImageView ivLogo;
    private TextView tvLogoText;
    private ViewPropertyAnimatorCompat viewAnimator;
    private int secondTime = ${secondTime};
	
	@Inject
	SplashPresent splashPresent;

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.${activityLayoutName});
		getActivityComponent().inject(this);
        splashPresent.attachView(this);
        splashPresent.getUrl();

        tempPage = (ImageView) findViewById(R.id.temp_page);
		ivLogo = (ImageView) findViewById(R.id.onboard_iv_logo);
        tvLogoText = (TextView) findViewById(R.id.tv_logo_text);
        logoAnimation();
    }
	
	/**
     *  向上移动
     */
    private void logoAnimation(){
        ViewCompat.animate(ivLogo)
                .translationY(-200)
                .setStartDelay(STARTUP_DELAY)
                .setDuration(ANIM_ITEM_DURATION)
                .setInterpolator(new DecelerateInterpolator(1.2f))
                .start();

        viewAnimator = ViewCompat.animate(tvLogoText)
                .translationY(100).alpha(1)
                .setStartDelay(500)
                .setDuration(ANIM_ITEM_DURATION);
        viewAnimator.setInterpolator(new DecelerateInterpolator()).start();
    }
	
	@Override
    public void getUrlData(String data) {
        Glide.with(SplashActivity.this)
                .load(data)
                .into(tempPage);

        Observable.timer(secondTime, TimeUnit.SECONDS, AndroidSchedulers.mainThread())
                .subscribe(new Subscriber<Object>() {
                    @Override
                    public void onCompleted() {
                    }

                    @Override
                    public void onError(Throwable e) {
                        goToNextActivity();
                    }

                    @Override
                    public void onNext(Object o) {
                        tvLogoText.setVisibility(View.GONE);
                        ivLogo.setVisibility(View.GONE);
                        tempPage.setVisibility(View.VISIBLE);

                        Observable.timer(secondTime, TimeUnit.SECONDS, AndroidSchedulers.mainThread())
                                .map(new Func1<Long, Object>() {
                                    @Override
                                    public Object call(Long aLong) {
                                        goToNextActivity();
                                        return aLong;
                                    }
                                }).subscribe();

                    }
                });
    }

    @Override
    public void onFailure() {

    }

    private void goToNextActivity(){
        boolean isComeOver = ShareUtils.getValue("isComeOver", false);
        if (isComeOver){
            startActivity(new Intent(SplashActivity.this, MainActivity.class));
        }else{
            startActivity(new Intent(SplashActivity.this, LaunchActivity.class));
        }
        finish();
    }
}
