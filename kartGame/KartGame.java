
import objectdraw.*;
import java.awt.*;

//ゲーム全体を制御するクラス
public class KartGame extends WindowController {
    private Kart car;
    private FramedRect leftButton, rightButton, backButton, accelerateButton;
    private Text left, right, back;
    private Raceway racewayA;
    private double openingTime, currentTime;
    private Text ins;

    @Override public void begin(){
        
        openingTime = System.currentTimeMillis();
        //ゲームスタートのカウントダウン
        ins = new Text("" ,0, 0, canvas);
        while(System.currentTimeMillis() -openingTime <= 8000 ){
            if(System.currentTimeMillis() -openingTime >= 5000 && System.currentTimeMillis() -openingTime < 6000 ){
                ins.setText("3");
                ins.setColor(Color.RED);
                ins.setFontSize(200);
                ins.moveTo(50+(800-ins.getWidth() )/2, 50+(500-ins.getHeight() )/2);
            }else if(System.currentTimeMillis() -openingTime >= 6000 && System.currentTimeMillis() -openingTime < 7000 ){
                ins.setText("2");
            }else if(System.currentTimeMillis() -openingTime >= 7000 && System.currentTimeMillis() -openingTime < 8000 ){
                ins.setText("1");
            }
        }
        
        //車のインスタンスとコース、左折/右折/バック/加速ボタンの生成
        car = new Kart(815, 340, canvas);
        car.moveForward();
        racewayA = new Raceway(10, 10, canvas, car);

        leftButton = new FramedRect(860, 350, 30, 30, canvas);
        left = new Text("L", 0, 0, canvas);
        left.moveTo(leftButton.getX()+(leftButton.getWidth()-left.getWidth())/2, leftButton.getY()+(leftButton.getHeight()-left.getHeight())/2);

        rightButton = new FramedRect(leftButton.getX()+40, leftButton.getY(), 30, 30, canvas);
        right = new Text("R",0, 0, canvas);
        right.moveTo(rightButton.getX()+(rightButton.getWidth()-right.getWidth())/2, rightButton.getY()+(rightButton.getHeight()-right.getHeight())/2);

        backButton = new FramedRect(leftButton.getX(), leftButton.getY()+40, 30, 30, canvas);
        back = new Text("back", 0, 0, canvas);
        back.moveTo(backButton.getX()+(backButton.getWidth()-back.getWidth())/2, backButton.getY()+(backButton.getHeight()-back.getHeight())/2);

        accelerateButton = new FramedRect(rightButton.getX(), backButton.getY(), 30, 30, canvas);
        new Mushroom(accelerateButton, 25, canvas);
       
        while(System.currentTimeMillis() -openingTime <= 9000 ){
            ins.setText("GO!!!");
            ins.moveTo(50+(800-ins.getWidth() )/2, 50+(500-ins.getHeight() )/2);

        }
        ins.removeFromCanvas();
    }

    //ボタンが押されている間の車の動きを変える
    @Override public void onMousePress(Location point){
        if(leftButton.contains(point) ){
            car.turnLeft();
        }else if(rightButton.contains(point) ){
            car.turnRight();
        }else if(backButton.contains(point) ){
            car.moveBackward();
        }else if(accelerateButton.contains(point) ){
            car.accelerate();
        }

    }

    //ボタンが離された時、車の動きを戻す
    @Override public void onMouseRelease(Location point){
        car.moveForward();
        car.stopAccelerate();
        car.stopTurning();
    }
}

