
import objectdraw.*;
import java.awt.*;

//コースを表現するためのクラス
public class Raceway extends ActiveObject {
    private FramedRect racewayFrame;
    private FilledRect[] wall;

    private Kart acar;
    private FramedRect checkPoint0, checkPoint1, checkPoint2; //全て順番に通過することで周回判定を行うチェックポイント
    private int point0Count = 0, point1Count = 0, point2Count = 0;
    private Text ins, time, lap1, lap2, lap3; 
    private double startTime, lap1Time, lap2Time, lap3Time;
    private boolean timing = true;

    public Raceway(double x, double y, DrawingCanvas acanvas, Kart akart){
        //一番大きな外枠
        racewayFrame = new FramedRect(50, 50, 800, 500, acanvas);
        //各障害物
        wall = new FilledRect[15];
        wall[0] = new FilledRect(500, 100, 300, 50, acanvas);
        wall[1] = new FilledRect(750, 150, 50, 300, acanvas);
        wall[2] = new FilledRect(250, 450, 550, 50, acanvas);
        wall[3] = new FilledRect(500, 350, 50, 100, acanvas);
        wall[4] = new FilledRect(500, 300, 100, 50, acanvas);
        wall[5] = new FilledRect(400, 50, 50, 350, acanvas);
        wall[6] = new FilledRect(450, 200, 200, 50, acanvas);
        wall[7] = new FilledRect(650, 200, 50, 200, acanvas);
        wall[8] = new FilledRect(100, 100, 250, 50, acanvas);
        wall[9] = new FilledRect(300, 150, 50, 300, acanvas);
        wall[10] = new FilledRect(100, 200, 150, 50, acanvas);
        wall[11] = new FilledRect(200, 250, 50, 150, acanvas);
        wall[12] = new FilledRect(100, 400, 100, 50, acanvas);
        wall[13] = new FilledRect(50, 300, 100, 50, acanvas);
        wall[14] = new FilledRect(50, 500, 100, 50, acanvas);
        new FramedRect(800, 300, 50, 3, acanvas); //周回のスタートライン
        checkPoint0 = new FramedRect(800, 250, 50, 50, acanvas);
        checkPoint0.hide();
        checkPoint1 = new FramedRect(350, 400, 50, 50, acanvas);
        checkPoint1.hide();
        checkPoint2 = new FramedRect(250, 500, 50, 50, acanvas);
        checkPoint2.hide();
        acar = akart;
        //lapのタイム表示
        ins = new Text("", 0, 0, acanvas);
        time = new Text("TIME", 860, 50, acanvas);
        time.setFontSize(20);
        lap1 =new Text("LAP1", 860, 100, acanvas);
        lap1.setFontSize(20);
        lap2 =new Text("LAP2", 860, 150, acanvas);
        lap2.setFontSize(20);
        lap3 =new Text("LAP3", 860, 200, acanvas);
        lap3.setFontSize(20);
        start();
        startTime = System.currentTimeMillis(); //ゲームスタート時の時間を保存

    }

    @Override public void run(){
        while(timing){
            time.setText("TIME" +(System.currentTimeMillis() -startTime)/1000 );
            //kartがコースの外枠、あるいは障害物に衝突したかをチェック
            if( acar.whetherMovingForward() & (this.contains(acar.getA()) || this.contains(acar.getD()) ) ){
                acar.stopMoving();
            }else if (acar.whetherMovingBackward() & (this.contains(acar.getB()) || this.contains(acar.getC())) ){
                acar.stopMoving();
            }
            //kartがチェックポイントに到達したかをチェック
            if(checkPoint0.contains(acar.getA() ) && point0Count == point2Count  ){
                point0Count++;
            }else if(checkPoint1.contains(acar.getB() ) && point1Count == point0Count-1 ){
                point1Count++;
            }else if(checkPoint2.contains(acar.getB() ) && point2Count == point1Count-1 ){
                point2Count++;
            }
            //karが周回したかをチェック
            if(point0Count == 2 && checkPoint0.contains(acar.getA() ) ){
                lap1Time = (System.currentTimeMillis() -startTime)/1000;
                lap1.setText("LAP1 " + lap1Time);
            }else if(point0Count == 3 && checkPoint0.contains(acar.getA() ) ) {
                lap2Time = (System.currentTimeMillis() - startTime)/1000 - lap1Time;
                lap2.setText("LAP2 " + lap2Time);
            }else if(point0Count == 4){
                lap3Time = (System.currentTimeMillis() - startTime)/1000 -lap1Time - lap2Time;
                lap3.setText("LAP3 " + lap3Time);
                timing = false;
                acar.playingSwitch();
            }

            pause(30);
        }
    }

    public boolean contains(Location a){
        boolean result = false;
        if(!racewayFrame.contains(a) ){
            result = true;
        }
        for(int wallPlace = 0; wallPlace < wall.length && result == false; wallPlace ++){ 
            if(wall[wallPlace].contains(a)  ){
                result = true;
            }
        }
        return result;
    }

    
}

