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

package com.bumpslide.ui {	import com.bumpslide.ui.skin.defaults.DefaultSliderSkin;	import com.bumpslide.data.type.Padding;	import com.bumpslide.events.DragEvent;	import com.bumpslide.ui.behavior.DragBehavior;	import com.bumpslide.data.constant.Direction;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.geom.Rectangle;	// events dispatched by dragBehavior (handle is target)	[Event(name="bumpslideDragStop", type="com.bumpslide.events.DragEvent")]			[Event(name="bumpslideDragMove", type="com.bumpslide.events.DragEvent")]			[Event(name="bumpslideDragStart", type="com.bumpslide.events.DragEvent")]	[Event(name="onSliderChange", type="com.bumpslide.events.UIEvent")]	/**	 * Base Class for Sliders and Scroll Handles	 * 	 * The basis for this class is the slider component by Keith Peters	 * (com.bit101.components.Slider, version 0.91)	 * 	 * David modified this to make it usable as a scroll bar and changed it	 * to support handle and background assets placed on the stage.	 * 	 * If a 'handle' or 'background' clips are not found, they are drawn 	 * programmatically as in Keith's original component.  If they are found, 	 * we use the x,y position of the handle to determine padding and constraints.	 * 	 * Be sure to uncheck the 'Automatically declare stage instances' option in 	 * your FLA publish settings.  	 * 	 * David's modifications:	 *  - added scrollTarget support	 *  - added handleSize, maxHandlePosition, and handlePosition getters	 *  - refactored event handlers to use these values	 *  - general cleanup and refactoring	 * 	 * Changes:	 * - 2008-11-03 : refactored to use DragBehavior	 * - 2010-xx-xx : refactored to use Bumpslide_UI skins	 * 	 * Released under the open source MIT License	 * http://www.opensource.org/licenses/mit-license.php	 */	public class Slider extends Component 	{		public static const EVENT_CHANGE:String = "onSliderChange";		// optional assets placed on timeline		// comment out if stage instaces are automatically		// declared in FLA publish settings		public var handle:Sprite;		public var background:Sprite;			// options		public var roundResults:Boolean = false;		public var minHandleSize:Number = 16;		public var notifyWhileDragging:Boolean = true;		public var fixedHandleSize:Number = 0;		protected var _padding:Padding = new Padding(0);				protected var _percent:Number = 0;		protected var _maxValue:Number = 100;		protected var _minValue:Number = 0;		protected var _orientation:String;				protected var _dragBehavior:DragBehavior;		//protected var _logarithmic:Boolean = false;		// our scrollable content			protected var _scrollTarget:IScrollable;		static public var DefaultSkinClass:Class = DefaultSliderSkin;				/**		 * Constructor		 * @param parent The parent DisplayObjectContainer on which to add this Slider.		 * @param xpos The x position to place this component.		 * @param ypos The y position to place this component.		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).		 */		public function Slider(orientation:String = "horizontal") 		{				_orientation = orientation;			//delayUpdate = false;			//debugEnabled = true;			super();		}		override protected function postConstruct():void 		{			super.postConstruct();			if(skin==null && skinClass==null) {				skinClass = DefaultSkinClass;			}		}				//---------------------		// Overrides		//---------------------						/**		 * Register skin parts and add listeners		 */		override protected function initSkin():void 		{			super.initSkin();						background = getSkinPart('background');			handle = getSkinPart('handle');						if(handle) {				// drag using mouse down events from anywhere inside this component				_dragBehavior = DragBehavior.init(handle, null);				handle.addEventListener(DragEvent.EVENT_DRAG_START, handleDragStart); // mouse down				handle.addEventListener(DragEvent.EVENT_DRAG_MOVE, handleDragMove); // mouse move				handle.addEventListener(DragEvent.EVENT_DRAG_STOP, handleDragStop); // mouse up/leave			}						if(background) background.addEventListener(MouseEvent.MOUSE_DOWN, handleBackgroundMouseDown);		}				/**		 * Remove skin parts and remove listeners		 */		override protected function destroySkin():void 		{						// drag using mouse down events from anywhere inside this component			DragBehavior.destroy(handle);			_dragBehavior = null;						if(handle) {				handle.removeEventListener(DragEvent.EVENT_DRAG_START, handleDragStart); // mouse down				handle.removeEventListener(DragEvent.EVENT_DRAG_MOVE, handleDragMove); // mouse move				handle.removeEventListener(DragEvent.EVENT_DRAG_STOP, handleDragStop); // mouse up/leave			}						if(background) background.removeEventListener(MouseEvent.MOUSE_DOWN, handleBackgroundMouseDown);						background = null;			handle = null;						super.destroySkin();		}				override protected function commitProperties():void 		{
			super.commitProperties();			updateDragBounds();
		}


		override protected function draw():void
		{
			
			super.draw();
			
		}
						///////////////////////////////////		// event handlers		///////////////////////////////////		private function handleBackgroundMouseDown(event:MouseEvent):void 		{						// figure out where we are			var pos:Number = isVertical ? mouseY - padding.top : mouseX - padding.left;			pos -= getHandleSize() / 2; // center handle at mouse loc						percent = pos/getHandleBounds();			//percent = Math.max(0, Math.min(bounds, pos - getHandleSize() / 2)) / bounds;//			//			if(logarithmic) {		//				var loglow:Number = Math.log(minValue);//				var loghigh:Number = Math.log(maxValue);		//				value = Math.exp(pct * (loghigh - loglow) + loglow);//			} else {//				value = pct * (maxValue - minValue) + minValue;//			}
						// notify our friends			notifyChanged();			
			invalidate( VALID_SKIN_STATE );
						// render now - we need the handle to be at it's new loc before we start dragging			updateNow();						_dragBehavior.startDragging(event);		}				private function handleDragStart(event:DragEvent):void 		{			// keep bounds updated			updateDragBounds();		}				/**		 * Handles drag start and move events		 */				private function handleDragMove(event:DragEvent):void 		{			//var handleLoc:Number = (isVertical) ? handle.y - padding.top : handle.x - padding.left;			percent = getActualHandlePosition() / getHandleBounds();		    			// notify our friends			notifyChanged();						if(handle is Button) (handle as Button).skinState = Button.STATE_OVER;				}						/**		 * handles drag stop		 */		private function handleDragStop(event:DragEvent):void 		{			if(handle is Button) (handle as Button).skinState = Button.STATE_OFF;			notifyChanged();		}				/**		 * Updates drag boundary for drag behavior		 */		protected function updateDragBounds():void 		{			if(_dragBehavior==null) return;			if(isVertical) {				_dragBehavior.dragBounds = new Rectangle(padding.left, padding.top, 0, getHandleBounds());			} else {				_dragBehavior.dragBounds = new Rectangle(padding.left, padding.top, getHandleBounds(), 0);			}		}				/**		 * Dispatches a Change event		 */		protected function notifyChanged():void 		{			log('notifyChanged() value = ' + value);			if(!isDragging || notifyWhileDragging) {
				sendEvent(EVENT_CHANGE, value);
				sendChangeEvent('value', value);
			}			if(scrollTarget) scrollTarget.scrollPosition = value;		}				///////////////////////////////////		// getter/setters		///////////////////////////////////		/**		 * Sets / gets the current value of this slider.		 */		public function set value(v:Number):void {				if(isNaN(v)) v = 0;						if (maxValue > minValue) {				v = Math.max(Math.min(v, maxValue), minValue);			} else {				v = Math.max(Math.min(v, minValue), maxValue);			}						// convert value to a percentage, and save the percentage			percent = (v - minValue) / (maxValue - minValue);		}		/**		 * Current Value		 */		public function get value():Number 		{				var val:Number;			//			if(logarithmic) {		//				var loglow:Number = Math.log(minValue);//				var loghigh:Number = Math.log(maxValue);		//				val = Math.exp(percent * (loghigh - loglow) + loglow);//			} else {				// update value internally (this will place the handle where it needs to be)				val = percent * (maxValue - minValue) + minValue;//			}						if(roundResults) return Math.round(val);			else return val;		}				/**		 * Gets / sets the maximum value of this slider.		 */		public function set maxValue(m:Number):void {			_maxValue = m;			invalidate();		}				public function get maxValue():Number {			if(scrollTarget) return scrollTarget.totalSize - scrollTarget.visibleSize;			else return _maxValue;		}				/**		 * Gets / sets the minimum value of this slider.		 */		public function set minValue(m:Number):void {			_minValue = m;			invalidate();		}				public function get minValue():Number {			return _minValue;		}				/**		 * Handle height for vertical sliders, width for horizontal		 */		public function getHandleSize():Number {						if(fixedHandleSize>0) {				return fixedHandleSize;			} 						if(scrollTarget != null) {				var total_size:Number = scrollTarget.totalSize;				if(total_size == 0 || isNaN(total_size)) total_size = .00001;				var bgSize:Number = (!isVertical) ? width - padding.width : height - padding.height;				var size:Number = scrollTarget.visibleSize / total_size * bgSize;						return Math.round(Math.min(bgSize, Math.max(size, minHandleSize)));			} else {				// just make it square unless 				return (!isVertical) ? height - padding.height : width - padding.width;			}		}				/**		 * This is the current handle position after compensation for padding		 */		public function getActualHandlePosition():Number {			return (isVertical) ? handle.y - padding.top : handle.x - padding.left ; 		}					/**		 * This is where the handle should be based on scale, padding, orientation, etc.		 */		public function getCalculatedHandlePosition():Number {			var pct:Number;			//			if(logarithmic) {//				var loglow:Number = Math.log(minValue);//				var loghigh:Number = Math.log(maxValue);	//				pct = (Math.log(value) - loglow) / (loghigh - loglow);//			} else { 				pct = (value - minValue) / (maxValue - minValue);			//}			var pos:Number = Math.round(pct * getHandleBounds());			if(isVertical) {				pos += padding.top;			} else {				pos += padding.bottom;			}			return pos;		}				/**		 * Shortcut for handle bounds rect length		 */		public function getHandleBounds():Number {			return ((!isVertical) ? width - padding.width : height - padding.height) - getHandleSize(); 		}				/**		 * scrollable content		 */		public function get scrollTarget():IScrollable {			return _scrollTarget;		}				/**		 * Makes slider a scroll handle by assigning scrollable content		 */		public function set scrollTarget( scrollContent:IScrollable ):void {						_scrollTarget = scrollContent;						maxValue = scrollContent.totalSize - scrollContent.visibleSize;			value = 0;			invalidate();		}				public function get isDragging():Boolean {			return _dragBehavior!=null && _dragBehavior.isDragging;		}				public function get isVertical():Boolean {			return orientation == Direction.VERTICAL;		}				/**		 * Convenience method to set the three main parameters in one shot.		 * @param min The minimum value of the slider.		 * @param max The maximum value of the slider.		 * @param value The value of the slider.		 */		public function setSliderParams(min:Number, max:Number, val:Number):void 		{			this.minValue = min;			this.maxValue = max;			this.value = val;		}				override public function toString():String 		{			return "[Slider]";		}				public function get orientation():String {			return _orientation;		}				public function set orientation(orientation:String):void {			_orientation = orientation;			invalidate();		}		//		public function get logarithmic():Boolean {//			return _logarithmic;//		}////		//		public function set logarithmic(logarithmic:Boolean):void {//			_logarithmic = logarithmic;//			invalidate();//		}				/**		 * Padding surrounding handle		 */		public function set padding ( p:* ) : void {			_padding = Padding.create( p );			invalidate();		}						public function get padding () : Padding {			return _padding;		}						/**		 * Percent scrolled - between 0 and 1		 */		public function get percent():Number {			return _percent;		}						public function set percent(percent:Number):void {
			trace('percent='+percent);			_percent = Math.max(0, Math.min( 1, percent ) );			invalidate();		}
		
		public function set onChange( f:Function ) : void {
			addEventListener( EVENT_CHANGE, f, false, 0, true );
		}	}}