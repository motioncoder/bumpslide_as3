﻿/**
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

package com.bumpslide.tween {	import com.bumpslide.util.Delegate;		import flash.display.DisplayObject;	import flash.events.TimerEvent;	import flash.utils.*;	/**	* FTween is a target-based tweening utility. 	*  	* This is not a Tweener/TweenLite clone, as tweens here do not use the Penner equations, 	* and do not have a fixed duration.  The tweens last as long as they need to until the	* property is within a configurable distance of the target. 	*	* See the ftween examples bundled with this library for more info.	*  	* FTween adds about 4k to your swf.	*  	* 20 Nov 2008: 	*   Added new methods (smooth, linear, and stutter)	*   Added Tweener/TweenLite style autoAlpha support	*   Added fadeIn and fadeOut shortcut methods	* 	* @author David Knape	*/		public class FTween extends Object{		//------------------------------		// THE TWEENING METHODS		//------------------------------				/**		* Tweens object properties using simple ease out		*/		static public function easeOut( obj:Object, prop:String, target:*, gain:Number=.2, options:Object=null) : FTween {					return FTween.tween( obj, prop, target, Ease.Out, {gain:gain}, options );		}
		
		/**
		* Ease - uses default Easing (Ease.Default)
		*/
		static public function ease( obj:Object, prop:String, target:*, gain:Number=.15, options:Object=null) : FTween {		
			return FTween.tween( obj, prop, target, Ease.Default, {gain:gain}, options );
		}
		
		/**
		* Tweens object properties using simple ease out
		*/
		static public function easeIn( obj:Object, prop:String, target:*, ramp:Number=.15, options:Object=null) : FTween {		
			return FTween.tween( obj, prop, target, Ease.In, {ramp:ramp}, options );
		}
		
		/**
		* Tweens object properties using  the default ease out, but also eases in the target velocity
		*/
		static public function easeInOut( obj:Object, prop:String, target:*, gain:Number=.15, ramp:Number=.15, options:Object=null) : FTween {		
			return FTween.tween( obj, prop, target, Ease.InOut, {gain:gain, ramp:ramp}, options );
		}				/**		* Easing from target to current location - beacuse Beau wanted it		*/		static public function easeFrom( obj:Object, prop:String, target:*, gain:Number=.15, options:Object=null) : FTween {					var original_value:* = obj[prop];			obj[prop] = target;			return FTween.tween( obj, prop, original_value, Ease.Default, {gain:gain}, options );		}				/**		* Tweens a color value		*/		static public function easeColor( obj:Object, prop:String, target:Number, gain:Number=.15, options:Object=null) : FTween {					if(options==null) options = new Object();			options.minDelta = 4000;			return FTween.tween( obj, prop, target, Ease.Color, {gain:gain}, options );		}				/**		* Tweens using a spring-like behavior		*/		static public function spring( obj:Object,prop:String, target:Number, gain:Number=.1, friction:Number=.15, options:Object=null ): FTween {				if(options==null) options = new Object();			options.ignoreVelocity = false;			return FTween.tween( obj, prop, target, Ease.Spring, {gain:gain, friction:friction}, options );		}							/**		* Tweens at a flat rate (speed is in pixels per loop)		*/		static public function linear( obj:Object, prop:String, target:Number, speed:Number=10, options:Object=null): FTween {			return FTween.tween( obj, prop, target, Ease.Linear, {speed:speed}, options );		}					/**		* Stuttery tween, randomizes the gain at each step, but eventually gets there		*/		static public function stutter( obj:Object, prop:String, target:Number, gain:Number=.15, options:Object=null): FTween {			return FTween.tween( obj, prop, target, Ease.Stutter, {gain:gain}, options );		}					/**		* Easing with a max velocity to keep things smooth		* 		* This is good for scrollbars and things that you don't want moving to fast, or if		* you know that the tween is going to be constantly interrupted, and you want to keep		* things 'smooth'.		*/		static public function smooth( obj:Object, prop:String, target:Number, gain:Number=.3, maxVelocity:Number=10, options:Object=null): FTween {			return FTween.tween( obj, prop, target, Ease.Smooth, {gain:gain, maxVelocity:maxVelocity}, options );		}					//---------------------------------		// Fade Shortcuts		//---------------------------------				/**		 * Fade in an object and make sure visible is true		 */		static public function fadeIn( obj:DisplayObject, delay:Number=0, gain:Number=.15, onComplete:Function=null, onUpdate:Function=null ) : FTween {			return FTween.ease( obj, 'autoAlpha', 1, gain, { delay:delay, onComplete:onComplete, onUpdate:onUpdate, minDelta: .1} );		}				/**		 * Fade out an object using and set visible to false when done		 */				static public function fadeOut( obj:DisplayObject, delay:Number=100, gain:Number=.3, onComplete:Function=null, onUpdate:Function=null ) : FTween {			return FTween.ease( obj, 'autoAlpha', 0, gain, { delay:delay, onComplete:onComplete, onUpdate:onUpdate, minDelta: .08} );		}		/**		 * Stop prop tween on an obj, or stop all tweens on that object is the prop is null		 */		static public function stopTweening(obj:Object, prop:String=null) : void {				var ft:FTween;			if(prop!=null) {				ft = FTween.getInstance( obj, prop );
				if(ft!=null) ft.stop();			} else {				// stop all tweens for this object				for each (ft in ActiveTweens[obj]) {					ft.stop();				}			}		}								/**		* There is only one tweener allowed per movie clip, per prop		* 		* This function is used by the static public functions to get that instance		*/		static private function getInstance(obj:Object, prop:String):FTween {			if(obj==null) {				return null;			}				if(ActiveTweens[obj]==null) ActiveTweens[obj] = new Dictionary();			if(ActiveTweens[obj][prop]==null) ActiveTweens[obj][prop] = new FTween( obj, prop, new Privacy() );			return ActiveTweens[obj][prop] as FTween;		}						/**		 * Tween a property of an object		 */		static public function tween( obj:Object, prop:String, target:*, easingFunc:Function=null, easingParams:Object=null, ftweenOptions:Object=null ) : FTween {						if(obj==null) {				trace('[FTween] attempt to tween null object.');				return null; 			}						// autoAlpha is really just alpha, leave a note in easingParams, so we 			// can take care of this later			if(prop=='autoAlpha' && obj is DisplayObject) {								prop='alpha';				if(easingParams==null) easingParams={};				easingParams.autoAlpha=true;												var dispObj:DisplayObject = obj as DisplayObject;				if(!dispObj.visible) dispObj.alpha = 0;							}									var ft:FTween = FTween.getInstance( obj, prop );							// kill delays on active tween and nullify any old update and complete handlers			Delegate.cancel( ft._delayTimer );			ft._options.onComplete = null;			ft._options.onUpdate = null;						if(ftweenOptions && ftweenOptions.delay) {				ft._delayTimer = Delegate.callLater( ftweenOptions.delay, ft.update, target, easingFunc, easingParams, ftweenOptions ); 			} else {					ft.update( target, easingFunc, easingParams, ftweenOptions );			}			return ft;		}				/**		* whether or not a clip is tweening		* 		* @param	obj		* @return		*/		static public function isTweening( obj:Object, prop:String ) : Boolean {			return FTween.getInstance( obj, prop )._isTweening==true;		}				/**		 * Updated the tween target		 */		public function update( target:Number, easingFunc:Function=null, params:Object=null, options:Object=null ):void {						debug('Tweening ' + _object + '.' + _property + ' to ' + target);									_isTweening = true;						if(easingFunc==null) easingFunc = Ease.Default;					_target = target;			_easing = easingFunc;			_parameters = params;									// update options if found			if(options!=null) {				debug( '  Options:');				if(options is FTweenOptions) {					_options = (options as FTweenOptions).clone();				} else {					for( var optionName:String in options) {						try { 							debug('  - ' + optionName + '=' + options[optionName] );							_options[optionName] = options[optionName]; 						} catch (e:Error) { 							warn('Invalid Option ' + optionName );						}					}				}			}						// init current value and velocity if they don't already exist			//if(_current==null) 			_current = _object[_property];			if(_velocity==null) _velocity = 0;						// clear any old delays			Delegate.cancel( _delayTimer );						// kill the timeout and update timers			Delegate.cancel( _timeoutTimer );									_updateTimer.reset();			_updateTimer.delay = _options.updateDelay;						// start the update loop			if(_current!=_target) {													// no tween should take longer than options.maxTime							_timeoutTimer = Delegate.callLater( _options.maxTime, handleTimeout );								// start updateLoop				if(!_updateTimer.running) {					_updateTimer.start();					updateLoop();				}				//updateLoop(); // 								} else {				finish(); 			}		}				/**		* Stops this tween		*/		public function stop(killPending:Boolean=true):void {									if(_updateTimer) _updateTimer.reset();			Delegate.cancel( _timeoutTimer );						if(killPending) {				Delegate.cancel(_delayTimer);							}			if(_delayTimer==null || !_delayTimer.running) {				// remove active tween				delete ActiveTweens[object][property];			}			_isTweening = false;			_velocity = 0;				// call onUpdate callback one last time			if(_options.onUpdate is Function) {				try { 					_options.onUpdate.call( null, this  );				} catch (e:Error) {					_options.onUpdate.call( null );				}			}			_options = new FTweenOptions();				}		/**		 * returns string identifying this tween		 */		public function toString () : String {			var o:String;			try {				o = _object.name;			} catch (e:Error) {				o = String( _object );			}			return '[FTween '+this._id+' ('+o+'.'+_property+')] ';		}												//---------------		// Private 		//---------------						/**		 * Creates a new FTween for a given object and property		 * 		 * This is private to ensure that tweens are re-used where applicable.		 * Use the static method FTween.tween(...) to initiate/update a tween.		 * Better yet, use the static shortcuts: FTween.ease, FTween.spring, etc.		 */		function FTween(object:Object, property:String, priv:Privacy) {			_id = ++FTween.LastTweenId;			_object = object;			_property = property;			_options = new FTweenOptions();			_updateTimer = new Timer( _options.updateDelay, 0);			_updateTimer.addEventListener( TimerEvent.TIMER, updateLoop, false, 0, true );		}						/**		 * This is the main animation loop		 * 		 * It is run using an old fashioned interval, _updateInt which is 		 * cleared and reset on every iteration to accomodate potential changes 		 * to options.updateDelay.		 */		private function updateLoop(e:TimerEvent=null):void {			// previous velocity 			var previous_velocity:Number = _velocity;						// apply easing			_velocity = _easing.call( null, _current, _target, _velocity, _parameters );			_current += _velocity;								// set the property and round if necessary			_object[_property] = (_options.keepRounded) ? Math.round(_current) : _current;										if(_parameters.autoAlpha) {				DisplayObject(_object).visible=true;			}							// trace			debug( 'updated.  current:'+_current + ' target:'+ _target + ' veloc:' + _velocity );						// call onUpdate callback			if(_options.onUpdate is Function) {				try { 					_options.onUpdate.call( null, this  );				} catch (e:Error) {  // ArgumentError or TypeError					_options.onUpdate.call( null );				}			}									// if result is to be rounded, no need to get too precise			if(_options.keepRounded) _options.minDelta = Math.max( _options.minDelta, .5 );						var dist_from_target:Number = _abs(_target-_current);			var close_enough:Boolean = dist_from_target <= _options.minDelta;			var slow_enough:Boolean = _options.ignoreVelocity || (_abs(_velocity) <= _options.minVelocity);			var stopped:Boolean = _velocity==0 && previous_velocity==0;						// if we are close and not moving very fast, or if we aren't moving anymore, then finish up			if ( close_enough && slow_enough) { 				debug('close enough, distance='+dist_from_target );				finish(); 			} else if ( stopped ) {				warn('no longer moving, distance='+dist_from_target);				finish();			} else {								// call the update loop again				//_updateInt = setInterval( updateLoop, _options.updateDelay);			}					}				/**		 * clears intervals, sets property to target, and calls onComplete callback		 */		private function finish():void {							// go to target						_object[_property] = _current = _target;				if(_parameters.autoAlpha && _target==0) {				DisplayObject(_object).visible=false;			}												// call onComplete callback if there is one			if(_options.onComplete is Function) {				try { 					_options.onComplete.call( null, this  );				} catch (e:Error) {  // ArgumentError or TypeError					_options.onComplete.call( null );				}			}						// stop update loop and reset			stop(false);		}				// faster abs		private function _abs(n:Number) : Number {			return n<0 ? -n : n;		}				// trace debug msg if traces are enabled		private function debug( msg:String ) : void  {			if(_options.debug) trace(this + ' ' + msg );		}				// trace warning msg		private function warn( msg:String ) : void  {			trace(this + ' Warning: ' + msg );		}				/**		 * If tween is taking too long, exit		 */		private function handleTimeout():void {			warn('tween timed out. this is not fatal. tweak your tween parameters and/or extend options.maxTime if this is being called prematurely');			finish();		}				public function get property () : String {			return _property;		}				public function get object () : Object {			return _object;		}				public function get target () : * {			return _target;		}		public function get current () : * {			return _current;		}		public function get velocity () : * {			return _velocity;		}				// used to generate tween ID (_id) 		static private var LastTweenId:Number=-1;				// dictionary of tweens		static private var ActiveTweens:Dictionary = new Dictionary(true);						// unique ID, so we can verify that tween are being reused		private var _id:Number = 0;							// ftween options (not easing params)		private var _options : FTweenOptions;				// tween info		private var _object : Object;				private var _property : String;		private var _easing : Function;		private var _parameters : Object;				// state		private var _target : *;		private var _current : *;		private var _velocity : *;			private var _isTweening : Boolean = false;					// timers for update loop, delay, and timeouts		private var _updateTimer:Timer;		private var _delayTimer:Timer;		private var _timeoutTimer:Timer;	}}// hack for private constructorclass Privacy {}