package native3d.core;
//{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class Camera3D extends Node3D
	{
		private var _fieldOfViewY:Float;
		private var _aspectRatio:Float;
		private var _zNear:Float;
		private var _zFar:Float=400000;
		public var invert:Matrix3D;// = new Matrix3D();
		public var perspectiveProjection:Matrix3D;// = new Matrix3D();
		
		public var viewMatrix:Matrix3D;// = new Matrix3D();
		public var perspectiveProjectionMatirx:Matrix3D;// = new Matrix3D();
		public var invertVersion:Int = -212;
		public var frustumPlanes:Vector<Vector3D>;
		
		public var is2d:Bool = false;
		public var cscale:Vector3D;
		public var cpos:Vector3D;
		public function new(width:Int,height:Int,is2d:Bool=false,index2d:Float=0) 
		{
			super();
			this.is2d = is2d;
			invert = new Matrix3D();
			perspectiveProjection = new Matrix3D();
			viewMatrix = new Matrix3D();
			perspectiveProjectionMatirx = new Matrix3D();
			add(new Node3D());
			
			cscale = new Vector3D(1,-1,1);
			cpos = new Vector3D(-1,1,index2d);
			if (is2d) {
				_zNear = 0;
				orthoLH(width, height, _zNear, _zFar,cscale,cpos);
			}else {
				_zNear = 1;
				perspectiveFieldOfViewLH(Math.PI / 4, width/height, _zNear, _zFar);
			}
			
			parent = new Node3D();
			if(!is2d)
			frustumPlanes = Vector.ofArray([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		}
		public function perspectiveFieldOfViewLH(fieldOfViewY:Float, 
												 aspectRatio:Float, 
												 zNear:Float, 
												 zFar:Float):Void {
			_zFar = zFar;
			_zNear = zNear;
			_aspectRatio = aspectRatio;
			_fieldOfViewY = fieldOfViewY;
			var yScale:Float = 1.0/Math.tan(fieldOfViewY/2.0);
			var xScale:Float = yScale / aspectRatio; 
			var vs:Vector<Float> = Vector.ofArray([
				xScale, 0, 0, 0,
				0, yScale, 0, 0,
				0, 0, zFar/(zFar-zNear), 1,
				0,0,zNear*zFar/(zNear-zFar),0
			]);
			
			#if flash
			perspectiveProjection.copyRawDataFrom(vs);
			#else
			perspectiveProjection.rawData = vs;
			#end
			
			invertVersion = -3;
		}
		
		public function orthoLH(width:Float, height:Float, zNear:Float, zFar:Float,scale:Vector3D,pos:Vector3D):Void {
			_zFar = zFar;
			_zNear = zNear;
			cscale = scale;
			cpos = pos;
			var rawData =Vector.ofArray([
				2.0/width, 0.0, 0.0, 0.0,
				0.0, 2.0/height, 0.0, 0.0,
				0.0, 0.0, 1.0/(zFar-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]);
			#if flash
			perspectiveProjection.copyRawDataFrom(rawData);
			#else
			perspectiveProjection.rawData = rawData;
			#end
			perspectiveProjection.appendScale(scale.x, scale.y, scale.z);
			perspectiveProjection.appendTranslation(cpos.x, cpos.y, cpos.z);
			invertVersion = -3;
		}
		
		public function resize(width:Int, height:Int):Void {
			var i3d = Instance3D.current;
			if (is2d) {
				orthoLH(i3d.width, i3d.height, _zNear, _zFar,cscale,cpos);
			}else {
				perspectiveFieldOfViewLH(Math.PI / 4, i3d.width/i3d.height, _zNear, _zFar);
			}
		}
		
		/**
		*   Get the distance between a point and a plane
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to get the distance between
		*   @param plane Plane to get the distance between
		*   @return The distance between the given point and plane
		*/
		private inline static function pointPlaneDistance(point:Vector<Float>, plane:Vector3D): Float
		{
			// plane distance + (point [dot] plane)
			return (plane.w + (point[12]*plane.x + point[13]*plane.y + point[14]*plane.z));
		}
 
		/**
		*   Check if a point is in the viewing frustum
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to check
		*   @return If the given point is in the viewing frustum
		*/
		public function isPointInFrustum(point:Vector<Float>,radius:Float):Bool
		{
			for (plane in frustumPlanes)
			{
				if (pointPlaneDistance(point, plane) < -radius)
				{
					return false;
				}
			}
			return true;
		}
	}

//}