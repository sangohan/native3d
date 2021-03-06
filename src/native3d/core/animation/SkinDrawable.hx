package native3d.core.animation;
import flash.Vector;
import native3d.core.ByteArraySet;
import native3d.core.Drawable3D;
import native3d.core.VertexBufferSet;
import native3d.materials.MaterialBase;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkinDrawable extends Drawable3D
{
	
	public var cacheBytes:Vector<ByteArraySet>;
	
	public var weightBuff:VertexBufferSet;
	public var matrixBuff:VertexBufferSet;
	public var material:MaterialBase;
	public function new() 
	{
		super();
	}
	
}