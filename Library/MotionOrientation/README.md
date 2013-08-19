MotionOrientation
=================

An observer to notify the orientation of iOS device changed, using CoreMotion for taking the orientation in &#39;Orientation Lock&#39;.


Requirements
============

This codes are under ARC.

These frameworks are needed.

<pre>
CoreMotion.framework
CoreGraphics.framework
</pre>


Usage
=====

Run below.

<pre>
[MotionOrientation initialize];
</pre>

Then you can receive notifications below.

<strong>MotionOrientationChangedNotification</strong>, when the device orientation changed.
<strong>MotionOrientationInterfaceOrientationChangedNotification</strong>, just when the interface orientation changed.

And then you can retrieve orientation informations.
<pre>
UIInterfaceOrientation interfaceOrientation = [MotionOrientation sharedInstance].interfaceOrientation;
UIDeviceOrientation deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation;
</pre>