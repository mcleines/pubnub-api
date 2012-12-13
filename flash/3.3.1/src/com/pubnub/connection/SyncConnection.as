package com.pubnub.connection {
	import com.pubnub.Errors;
	import com.pubnub.log.Log;
	import com.pubnub.net.URLLoaderEvent;
	import com.pubnub.operation.Operation;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class SyncConnection extends Connection {
		
		protected var _timeout:int = 310000;
		protected var timeoutInterval:int;
		private var busy:Boolean;
		
		public function SyncConnection(timeout:int = 310000) {
			super();
			_timeout = timeout;
		}
		
		
		override public function sendOperation(operation:Operation):void {
			//trace('sendOperation : ' + operation.url);
			super.sendOperation(operation);
			if (ready) {
				doSendOperation(operation);
			}else {
				if (loader.connected == false) {
					loader.connect(operation.request);
				}
				queue.push(operation);
			}
		}
		
		private function doSendOperation(operation:Operation):void {
			if (busy) return;
			clearTimeout(timeoutInterval);
			timeoutInterval = setTimeout(onTimeout, _timeout);
			busy = true;
			if (operation.destroyed) {
				sendNextOperation();
			}else {
				this.operation = operation;
				loader.load(operation.request);
			}
		}
		
		private function onTimeout():void {
			if (operation && !operation.destroyed) {
				logTimeoutError(operation);
				operation.onError({message:Errors.OPERATION_TIMEOUT, operation:operation});
			}
			busy = false;
			operation = null;
			sendNextOperation();
		}
		
		private function logTimeoutError(operation:Operation):void {
			var args:Array = [Errors.OPERATION_TIMEOUT];
			var op:Operation = getLastOperation();
			if (op) {
				args.push(op.url);
			}
			Log.log(args.join(','), Log.ERROR, Errors.OPERATION_TIMEOUT);
		}
		
		private function sendNextOperation():void {
			if (queue.length > 0) {
				doSendOperation(queue.shift());
			}
		}
		
		override protected function onClose(e:Event):void {
			super.onClose(e);
			var resendLastOperation:Boolean = (operation && operation.completed == false);
			trace(this, ' onClose : ' + resendLastOperation, operation);
			if (resendLastOperation) {
				sendOperation(operation);
			}else {
				sendNextOperation();
			}
		}
		
		override public function close():void {
			queue.length = 0;
			super.close();
			busy = false;
			clearTimeout(timeoutInterval);
		}
		
		override protected function onConnect(e:Event):void {
			trace(this, 'onConnect');
			super.onConnect(e);
			sendNextOperation();
		}
		
		override protected function get ready():Boolean {
			return super.ready && !busy;
		}
		
		override protected function onComplete(e:URLLoaderEvent):void {
			//trace('onComplete : ' + operation.url)
			clearTimeout(timeoutInterval);
			super.onComplete(e);
			busy = false;
			sendNextOperation();
		}
	}
}