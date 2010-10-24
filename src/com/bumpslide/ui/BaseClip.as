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

package com.bumpslide.ui {	import com.bumpslide.util.ObjectUtil;
	import com.bumpslide.ui.skin.ISkin;
	import com.bumpslide.events.UIEvent;	import com.bumpslide.util.Delegate;		import flash.display.DisplayObject;	import flash.display.MovieClip;	import flash.geom.ColorTransform;	import flash.utils.getQualifiedClassName;		/**     * Base Class for MovieClips that just want access to the shortcut methods provided here.     *      * If your class is a component that needs a validation model for data and sizing,      * you should extend Component instead.     *      * @author David Knape     */    public class BaseClip extends MovieClip {    			public var logEnabled:Boolean = false;
		private var _initializing:Boolean = false;
				function BaseClip() {
			_initializing = true;
    		init();
    		_initializing = false;    	}	
				/**		 * Displays object as "[Classname:instanceName]"		 */		override public function toString():String {			var classname:String = getQualifiedClassName(this).split('::').pop();						return "["+classname+":"+name+"]";
		}				/**		 * Initialize		 */
		protected function init() : void {    		    	}    	    	/**    	 * Destroy    	 */    	public function destroy() : void {    	    	}    							/**		 * Dispatches a UIEvent which is a bubbling event with a data holder		 */		protected function sendEvent( type:String, data:Object=null ) : void {			UIEvent.send( this, type, data );		}						/**		 * Delegate that swallows input (like an event or some callback info) and calls your delegate		 * 		 * This is seful for cases where an event should trigger an existing function.		 * 		 * Example:		 *   my_btn.addEventListener( MouseEvent.CLICK, Link.to, "http://yahoo.com/" );		 * 		 */		protected function eventDelegate( func:Function, ...args ) : Function {			var delegate:Function = Delegate.create.apply( null, [func].concat(args) );			return function (...rest) : void { delegate.call(); };		}			/**		 * Safely remove child (no errors) and call its destroy method if it has one		 */		public function destroyChild( child:DisplayObject ):void {			if(child!=null) {				if (child is BaseClip) {				 	(child as BaseClip).destroy();				} else if(child is ISkin) {				 	(child as ISkin).destroy();				}				if (child.parent!=null) {					child.parent.removeChild(child);				}			}		}				/**		 * changes the color of a movieclip		 */		protected function colorize( mc:DisplayObject, color:uint ) : void {			var current_alpha:Number = mc.alpha;			if(isNaN(color)) {				mc.transform.colorTransform = null;			} else {				var ct:ColorTransform = new ColorTransform();				ct.color = color;				mc.transform.colorTransform = ct;			}			mc.alpha = current_alpha;		}				/**		 * creates an instance of a class, sets properties found in initObj, and 		 * tries to add it to the stage while returning an untyped result		 * that can be assigned to a variable without casting		 * 		 * This is david's hacky javascripty mxml alternative.		 * 		 * Example:		 * 		 * private var closeButton:Button = add( Button, { 		 * 	label: "X", 		 * 	click: doClose,		 * 	alignH: "right -10",		 * 	y: 10		 * }		 * 		 * );		 * 		 * override protected function addChildren():void {		 *   closeButton = add( Button		 * }		 */		public function add( classs:Class, initObj:Object = null):* 		{			return addChild( ObjectUtil.create( classs, initObj ) );		}				/**		 * Trace		 */		protected function log( s:* ) : void {			if(logEnabled) trace( this + ' ' + s );		}				//-------------------------------		// shortcuts to Delegate methods		//--------------------------------		   		protected var d:Function = Delegate.create; 	    	protected var delegate:Function = Delegate.create;    	protected var callLater:Function = Delegate.callLater;
		protected var cancelCall:Function = Delegate.cancel;
		protected var create:Function = ObjectUtil.create;

		public function get initializing():Boolean {
			return _initializing;
		}		    	    	    }}