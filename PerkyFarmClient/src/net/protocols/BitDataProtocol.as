package net.protocols 
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import net.serialize.UTFBitSerializer;

	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BitDataProtocol extends CompressedUTFDataProtocol 
	{
		
		public function BitDataProtocol(receiveHandler:Function, socket:Socket = null, forceReconnection:Boolean = false) 
		{
			super(null, receiveHandler, socket, forceReconnection);
		}
		
		override public function send(object:*):void
		{
			var byteArray:ByteArray = object as ByteArray;
			if (!isOpen && !_forceReconnection && !_connecting)
				throw("Protocol closed");
			if (!_busy && _queue.length == 0 && isOpen)
				sendNext(byteArray); // если очередь пуста и передача доступна, форсируем
			else
				_queue.push(byteArray); // транспорт занят, положим в очередь
		}
		
		override protected function dataReceiveHandler(event:ProgressEvent):void
		{
			if (_bytesTotal == 0) {
				// инициализируем как новый пакет
				_currentPackage = new ByteArray();
				_bytesTotal = _socket.readInt();
			}
			if (!_socket.bytesAvailable) return;
			var numBytes:Number = Math.min(_bytesTotal - _currentPackage.length, _socket.bytesAvailable);
			_socket.readBytes(_currentPackage, _currentPackage.length, numBytes);
			if (_currentPackage.length == _bytesTotal) {
				// завершим работу с пакетом
				var byteArray:ByteArray = _currentPackage;
				_currentPackage = null;
				_bytesTotal = 0;
				// передаем готовый объект получателю
				_receiveHandler(this, byteArray);
			}
		}
	}

}