
import objectdraw.*;
import java.awt.*;

//きのこの絵を描画するクラス
public class Mushroom extends WindowController {
    
    public Mushroom(FramedRect box, double size, DrawingCanvas acanvas){
        new FilledOval(box.getX() + (box.getWidth()- size/2)/2, box.getY()+5+size/2, size/2, size/3, acanvas).setColor(Color.ORANGE);
        new FilledOval(box.getX() + (box.getWidth()-size)/2, box.getY()+5, size, size*2/3, acanvas).setColor(Color.RED );
        new FilledOval(box.getX() + (box.getWidth()-size)/2 + size*3/10, box.getY()+5+size*2/15, size*2/5, size*2/5, acanvas).setColor(Color.WHITE );
    }
}