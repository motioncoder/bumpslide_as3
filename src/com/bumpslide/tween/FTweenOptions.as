/**
 * This code is part of the Bumpslide Library maintained by David Knape
 * Fork me at http://github.com/tkdave/bumpslide_as3
 * 
 * Copyright (c) 2010 by Bumpslide, Inc. 
 * http://www.bumpslide.com/
 *
 * This code is released under the open-source MIT license.
 * See LICENSE.txt for full license terms.
 * More info at http://www.opensource.org/licenses/mit-license.php
 */

package com.bumpslide.tween {	/**	 * These are the FTween options	 * 	 * @author David Knape	 */	public class FTweenOptions {				// default values					// how close we need to get to the target before we stop		public var minDelta:Number = .01;				// how slow we must be going before we stop (when springing)		public var minVelocity:Number = .01;
		
		// maximum speed regardless of tween equation
		public var maxVelocity:Number = 0;				// whether or not to check velocity		// (calling FTween.spring automatically sets this to false)		public var ignoreVelocity:Boolean = true;				// time after which we stop trying to update (default 20 seconds)		public var maxTime:int = 20000;				// whether or not to round results		// note that internal value (_current) is never rounded		// we only round the value when it is applied to the object being tweened		public var keepRounded:Boolean = false;				// animation loop interval in ms		public var updateDelay:uint = 30;				// delay before start		public var delay:uint = 0;				// show debug messages while tweening (warning, slows things down)		public var debug:Boolean = false;				// callbacks		public var onUpdate:Function;		public var onComplete:Function;				public function clone() : FTweenOptions {			var o:FTweenOptions=new FTweenOptions();			o.debug = debug;			o.delay = delay;			o.ignoreVelocity = ignoreVelocity;			o.keepRounded = keepRounded;			o.maxTime = maxTime;			o.minDelta = minDelta;			o.minVelocity = minVelocity;			o.maxVelocity = maxVelocity;			o.onComplete = onComplete;			o.onUpdate = onUpdate;			o.updateDelay = updateDelay;			return o;		}				public function FTweenOptions( delay:uint=0, min_delta:Number=.01, min_velocity:Number=.01, 									   update_delay:uint=30, keep_rounded:Boolean=false, debug:Boolean=false, 									   on_complete:Function=null, on_update:Function=null ) 		{			keepRounded = keep_rounded;			minDelta = min_delta;			minVelocity = min_velocity;			updateDelay = update_delay;			onComplete = on_complete;			onUpdate = on_update;			this.debug = debug;			this.delay = delay;					}	}}