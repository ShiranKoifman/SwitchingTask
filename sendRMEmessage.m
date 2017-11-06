function sendRMEmessage(channel,controlnumber,controlvalue)
% SENDRMEMESSAGE
% sends a MIDI CONTROL_CHANGE message to the RME Totalmix mixer. 
%
% Usage: sendRMEmessage(channel,controlnumber,controlvalue)
%
% Inputs: channel - which MIDI channel to send the message on. For the RME,
%               this will most often be channel 0.
%         controlnumber - which MIDI control number to address. These are 
%               integers between 0 and 127, inclusive.
%         value - which control value to send. These are integers between 0
%               and 1227, inclusive.
%
% Example: sendRMEmessage(0,7,25)
%   This will set the gain of the Monitor Main slider to a relatively low
%   value.
%
% 20120511 Eric Thompson

if(nargin<3)
    help sendRMEmessage
    error('sendRMEmessage:badinputs','Three inputs required')
end
if(~isscalar(channel) || channel<0 || channel > 15)
    help sendRMEmessage
    error('sendRMEmessage:badchannel','Parameter channel must be an integer between 0 and 15.')
end
if(~isscalar(controlnumber) || controlnumber<0 || controlnumber > 127)
    help sendRMEmessage
    error('sendRMEmessage:badcontrol','Parameter controlnumber must be an integer between 0 and 127.')
end
if(~isscalar(controlvalue) || controlvalue<0 || controlvalue > 127)
    help sendRMEmessage
    error('sendRMEmessage:badvalue','Parameter controlvalue must be an integer between 0 and 127.')
end
if(controlvalue~=round(controlvalue))
    warning('sendRMEmessage:nonintegervalue','Control value should be an integer.')
end

% load java libraries for MIDI
import javax.sound.midi.*

% get MIDI device
myDev = findMIDIyokeDevice;

myDev.open;

% get a receiver
myRcvr = myDev.getReceiver;
pause(0.1)
% set up a message handle
myMsg = ShortMessage;

myMsg.setMessage(ShortMessage.CONTROL_CHANGE,channel,controlnumber,controlvalue);
myRcvr.send(myMsg,-1)

%clean up
myDev.close();
end
%eof