
import objectdraw.*;
import java.awt.*;

//カートを表すクラス
public class Kart extends ActiveObject {
    private AngLine upper, lower, left, right;
    private double kartWidth = 20, kartHeight = 30; //kartの幅と長さ
    private static final int DELAY_TIME = 30; //コマ送りの時間
    private double step = 2.0; //kartの速度
    private double direction = 90; //kartの角度
    private double add = 0; //右左折時にkartを曲げる角度
    private boolean playing=true ,movingForward = true, movingBackward = false, turningLeft = false, turningRight = false, accelerating = false;

    public Kart(double x, double y, DrawingCanvas acanvas){
        //kartの外枠を表現するための線
        left = new AngLine(x, y, kartHeight, direction, acanvas);
        right = new AngLine(x+kartWidth, y-kartHeight, kartHeight, direction+180, acanvas);
        lower = new AngLine(x, y, kartWidth, direction-90, acanvas);
        upper = new AngLine(x+kartWidth, y-kartHeight, kartWidth, direction+90, acanvas);
        start();
    }

    //状態に応じた車の制御を行うために、具体的な操作を行う
    @Override public void run(){
        while(playing){
            if(movingBackward){ //後退
                step = -1.0;
                add = 0;
            }else if(movingForward){ //前進

                if(accelerating){ //きのこボタンが押されている
                    step = 4.0;
                }else{ //押されていない
                    step = 2.0;
                }
                if(turningLeft){ //左折時
                    add = +3.0;
                }else if(turningRight){ //右折時
                    add = -3.0;
                }else { //右左折していない時
                    add = 0;
                }
            }else {
                step = 0;
                add = 0;
            }

            //kartの外枠を表現する4本の辺を移動させる
            left.setStart( left.getStart().getX()+step*Math.cos((direction+add)*Math.PI/180), left.getStart().getY()-step*Math.sin((direction+add)*Math.PI/180) );
            left.setEnd( left.getStart().getX()+kartHeight*Math.cos((direction+add)*Math.PI/180), left.getStart().getY()-kartHeight*Math.sin((direction+add)*Math.PI/180) );
            lower.setStart( left.getStart() );
            lower.setEnd( lower.getStart().getX()+kartWidth*Math.cos((direction-90+add)*Math.PI/180), lower.getStart().getY()-kartWidth*Math.sin((direction-90+add)*Math.PI/180) );
            right.setStart(lower.getEnd().getX()+left.getEnd().getX()-left.getStart().getX(), lower.getEnd().getY()+left.getEnd().getY()-left.getStart().getY() );
            right.setEnd( lower.getEnd() );
            upper.setStart( right.getStart() );
            upper.setEnd( left.getEnd() );
            direction += add;

            pause(DELAY_TIME);
        }
    }

    public void playingSwitch(){
        if(playing){
            playing = false;
        }else {
            playing = true;
        }
    }

    public void turnLeft(){
        turningLeft = true;
    }

    public void turnRight(){       
        turningRight = true;
    }

    public void stopTurning(){
        turningLeft = false;
        turningRight = false;
    }

    public void moveForward(){
        movingForward = true;
        movingBackward = false;
    }

    public void moveBackward(){
        movingForward = false;
        movingBackward = true;
    }

    public void accelerate(){
        accelerating = true;
    }

    public void stopAccelerate(){
        accelerating = false;
    }

    public void stopMoving(){
        movingForward = false;
        movingBackward = false;
    }

    public boolean whetherMovingForward(){
        if(movingForward){
            return true;
        }else {
            return false;
        }
    }

    public boolean whetherMovingBackward(){
        if(movingBackward){
            return true;
        }else {
            return false;
        }
    }

    public Location getA(){
        return left.getEnd();
    }

    public Location getB(){
        return left.getStart();
    }

    public Location getC(){
        return right.getEnd();
    }

    public Location getD(){
        return right.getStart();
    }
}
