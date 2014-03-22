require "spec_helper"

describe Invoker::IPC::ClientHandler do
  let(:client_socket) { StringIO.new }
  let(:client) { Invoker::IPC::ClientHandler.new(client_socket) }

  describe "add command" do
    let(:message_object) { MM::Add.new(process_name: 'foo') }
    it "should run if read from socket" do
      invoker_commander.expects(:on_next_tick).with("foo")
      client_socket.string = message_object.to_json

      client.read_and_execute
    end
  end

  describe "remove command" do
    it "with specific signal" do
      message_object = MM::Remove.new(process_name: 'foo', signal: 'INT')
      invoker_commander.expects(:on_next_tick)
      client_socket.string = message_object.to_json

      client.read_and_execute
    end

    it "with default signal" do
      message_object = MM::Remove.new(process_name: 'foo')
      invoker_commander.expects(:on_next_tick)
      client_socket.string = message_object.to_json

      client.read_and_execute
    end
  end

  describe "invalid command" do
    before do
      @client_socket = double()
      @client = Invoker::IPC::ClientHandler.new(@client_socket)
    end

    it "should print error if read from socket" do
      invoker_commander.expects(:on_next_tick).never()
      @client_socket.expects(:gets).returns("eugh foo\n")

      @client.read_and_execute
    end
  end
end
