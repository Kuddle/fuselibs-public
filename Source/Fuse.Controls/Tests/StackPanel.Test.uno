using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Graphics;
using Uno.Testing;

using Fuse.Controls.Test.Helpers;
using Fuse.Elements;
using Fuse.Layouts;
using Fuse.Resources;
using FuseTest;

using FuseTest;

namespace Fuse.Controls.Test
{
	public class StackPanelTest : TestBase
	{
		[Test]
		public void AllElementProps()
		{
			var s = new StackPanel();
			ElementPropertyTester.All(s);
		}

		[Test]
		public void AllElementLayoutTests()
		{
			var s = new StackPanel();
			ElementLayoutTester.All(s);
		}

		[Test]
		public void AllPanelProps()
		{
			var s = new Panel();
			s.Layout = new StackLayout();
			PanelTester.AllSimpleTests(s);
		}

		[Test]
		public void AllPanelLayoutTets()
		{
			var s = new Panel();
			s.Layout = new StackLayout();
			PanelTester.AllLayoutTests(s);
		}

		[Test]
		public void OrientationTest()
		{
			var s = new StackPanel();
			Assert.AreEqual(Orientation.Vertical, s.Orientation);
			s.Orientation = Orientation.Horizontal;
			Assert.AreEqual(Orientation.Horizontal, s.Orientation);
		}

		[Test]
		public void ResetOrientationTest()
		{
			var s = new StackPanel();
			s.Orientation = Fuse.Layouts.Orientation.Horizontal;
			s.Orientation = Orientation.Vertical;
			Assert.AreEqual(Fuse.Layouts.Orientation.Vertical, s.Orientation);
		}

		[Test]
		public void HorizontalLayoutAlignmentTest()
		{
			var root = new TestRootPanel();
			var parent = new StackPanel();
			var child1 = GetChildForStackPanel(float4( 10, 5, 20, 15 ), 100, 50);
			var child2 = GetChildForStackPanel(float4( 10, 5, 0, 15 ), 250, 200);
			var child3 = GetChildForStackPanelWithoutWidth(float4( 8, 3, 7, 11 ), 77);
			var child4 = GetChildForStackPanel(float4( 8, 3, 9, 13 ), 277, 51);
			parent.Orientation = Orientation.Vertical;
			root.Children.Add(parent);

			child1.Alignment = Alignment.Left;
			parent.Children.Add( child1 );
			child2.Alignment = Alignment.HorizontalCenter;
			parent.Children.Add( child2 );
			child3.Alignment = Alignment.Default;
			parent.Children.Add( child3 );
			child4.Alignment = Alignment.Right;
			parent.Children.Add( child4 );

			root.Layout(int2(320, 500));
			LayoutTestHelper.TestElementLayout(child1, float2(100, 50), float2(10, 5));
			LayoutTestHelper.TestElementLayout(child2, float2(250, 200), float2((320 - 250 + 10) / 2, 75));
			LayoutTestHelper.TestElementLayout(child3, float2(320 - 15, 77), float2(8, 75 + 200 + 15 + 3));
			LayoutTestHelper.TestElementLayout(child4, float2(277, 51), float2(320 - 277 - 9, 293 + 77 + 3 + 11));

			parent.MaxWidth = 350;
			root.Layout(int2(500, 500));
			LayoutTestHelper.TestElementLayout(child3, float2(350 - 15, 77), float2(8, 75 + 200 + 15 + 3));
		}

		[Test]
		public void VerticalLayoutAlignmentTest()
		{
			var root = new TestRootPanel();
			var parent = new StackPanel();
			var child1 = GetChildForStackPanel(float4( 10, 5, 20, 15 ), 100, 50);
			var child2 = GetChildForStackPanel(float4( 10, 5, 0, 15 ), 300, 200);
			var child3 = GetChildForStackPanelWithoutHeight(float4( 8, 3, 7, 11 ), 201);
			var child4 = GetChildForStackPanel(float4( 8, 3, 9, 13 ), 277, 51);
			parent.Orientation = Orientation.Horizontal;
			root.Children.Add(parent);

			child1.Alignment = Alignment.Top;
			parent.Children.Add( child1 );
			child2.Alignment = Alignment.Bottom;
			parent.Children.Add( child2 );
			child3.Alignment = Alignment.Default;
			parent.Children.Add( child3 );
			child4.Alignment = Alignment.VerticalCenter;
			parent.Children.Add( child4 );

			root.Layout(int2(1000, 500));
			LayoutTestHelper.TestElementLayout(child1, float2(100, 50), float2(10, 5));
			LayoutTestHelper.TestElementLayout(child2, float2(300, 200), float2(130 + 10, 500 - 15 - 200));
			LayoutTestHelper.TestElementLayout(child3, float2(201, 500 - 14), float2(130 + 310 + 8, 3));
			LayoutTestHelper.TestElementLayout(child4, float2(277, 51), float2(448 + 201 + 7 + 8, (500 - 51 - 13 + 3) / 2f));

			parent.MaxHeight = 350;
			root.Layout(int2(1000, 500));
			LayoutTestHelper.TestElementLayout(child3, float2(201, 350 - 14), float2(130 + 310 + 8, 3));
		}

		[Test]
		public void LayoutAlignmentImageTest()
		{
			var root = new TestRootPanel();
			var parent = new StackPanel();
			parent.Orientation = Orientation.Vertical;
			root.Children.Add(parent);

			var child1 = new Image();
			child1.Height = 441;
			child1.StretchMode = StretchMode.Scale9;
			var image1Source = new TextureImageSource();
			image1Source.Texture = import Texture2D("Assets/713x441.png");
			image1Source.Density = 1.3f;
			child1.Source = image1Source;
			child1.Alignment = Alignment.HorizontalCenter;
			parent.Children.Add(child1);

			root.Layout(int2(928, 722));
			LayoutTestHelper.TestElementLayout(child1, float2(713, 441), float2((928-713)/2f, 0));
		}

		[Test]
		public void LayoutPercentDependent()
		{
			var root = new TestRootPanel();
			var parent = new StackPanel();
			parent.Orientation = Orientation.Vertical;
			parent.Alignment = Alignment.Center;
			parent.Mode = StackLayoutMode.TwoPass;
			root.Children.Add(parent);
			
			var c1 = new Panel();
			c1.Height = 10;
			c1.Width = Size.Percent(50);
			parent.Children.Add(c1);
			
			var c2 = new Image();

			c2.Width = Size.Percent(100);
			c2.Source = new TextureImageSource{ Texture = import Texture2D("Assets/200x100.png" ) };
			parent.Children.Add(c2);
			
			var c3 = new Panel();
			c3.Width = 400;
			c3.Height = 5;
			parent.Children.Add(c3);
			
			//https://github.com/Outracks/RealtimeStudio/issues/1632
			/*var c4 = new Panel();
			c4.Height = 10;
			c4.Width = Size.Percent(110);
			parent.Children.Add(c4);*/
			
			root.Layout(int2(1000,1000));

			LayoutTestHelper.TestElementLayout(c1, float2(200,10), float2(100,0) );
			LayoutTestHelper.TestElementLayout(c2, float2(400,200), float2(0,10) );
			//LayoutTestHelper.TestElementLayout(c4, float2(440,10), float2(-20,210) );
			LayoutTestHelper.TestElementLayout(parent, float2(400,215), float2((1000-400)/2f,(1000-215)/2f));
		}
		
		[Test]
		public void LayoutPercentFixed()
		{
			var root = new TestRootPanel(true);
			var parent = new StackPanel();
			parent.Orientation = Orientation.Horizontal;
			parent.Height = 200;
			root.Children.Add(parent);
			
			var c1 = new Panel();
			c1.Height = Size.Percent(10);
			c1.Width = 50;
			c1.Alignment = Alignment.Bottom;
			parent.Children.Add(c1);
			
			var c2 = new Image();
			c2.Source = new TextureImageSource{ Texture = import Texture2D("Assets/200x100.png" ) };
			parent.Children.Add(c2);
			
			var c3 = new Panel();
			c3.Height = Size.Percent(110);
			c3.Width = 10;
			parent.Children.Add(c3);
			
			root.Layout(int2(1000,1000));
			LayoutTestHelper.TestElementLayout(c1, float2(50,20), float2(0,180) );
			LayoutTestHelper.TestElementLayout(c2, float2(400,200), float2(50,0) );
			LayoutTestHelper.TestElementLayout(c3, float2(10,220), float2(450,-10) );
			LayoutTestHelper.TestElementLayout(parent, float2(1000,200), float2(0,400));
		}
		
		[Test]
		public void SecondPassAndResizeRequired()
		{
			var root = new TestRootPanel();
			var p = new UX.SecondPassAndResizeRequired();
			root.Children.Add(p);
			
			root.Layout(int2(500,1000));
			LayoutTestHelper.TestElementLayout(p, float2(80,625), float2((500-80)/2f,(1000-625)/2f));
			LayoutTestHelper.TestElementLayout(p.Area1, float2(80,125), float2(0,0));
			LayoutTestHelper.TestElementLayout(p.Area2, float2(40,250), float2(20,125));
			LayoutTestHelper.TestElementLayout(p.Area3, float2(40,250), float2(40,375));
		}
		
		[Test]
		public void ContentAlignment()
		{
			//using non-1 density to ensure ContentAlignment optimizations are valid (AdjustMarginBoxPosition)
			var root = new TestRootPanel(false, 0.75f);
			var p = new UX.ContentAlignment();
			root.Children.Add(p);
			root.Layout(int2(1000,500));
			
			Assert.AreEqual( float2(10.666687f,20), p.RA0.ActualPosition);
			Assert.AreEqual( float2(10.666687f,70.66665f), p.RA1.ActualPosition);
			Assert.AreEqual( float2(10.666687f,121.33334f), p.RA2.ActualPosition);
			
			Assert.AreEqual( float2(0,0), p.RB0.ActualPosition);
			Assert.AreEqual( float2(0,50.666668f), p.RB1.ActualPosition);
			Assert.AreEqual( float2(0,101.33334f), p.RB2.ActualPosition);
			
			Assert.AreEqual( float2(0,174.666672f), p.RC0.ActualPosition);
			Assert.AreEqual( float2(0,225.3333280f), p.RC1.ActualPosition);
			Assert.AreEqual( float2(0,276.00000f), p.RC2.ActualPosition);
			
			Assert.AreEqual( float2(-121.333313f,0), p.RD0.ActualPosition);
			Assert.AreEqual( float2(-70.666657f,0), p.RD1.ActualPosition);
			Assert.AreEqual( float2(-20.000000f,0), p.RD2.ActualPosition);
		}
		
		[Test]
		public void Issue1252()
		{
			var root = new TestRootPanel();
			var p = new UX.Issue1252();
			root.Children.Add(p);
			root.Layout(int2(1000));
			
			Assert.AreEqual(float2(750,100), p.E1.ActualSize);
			Assert.AreEqual(float2(125,450), p.E1.ActualPosition);
			Assert.AreEqual(float2(750,40), p.E2.ActualSize);
			Assert.AreEqual(float2(0,0), p.E2.ActualPosition);
			Assert.AreEqual(float2(750,40), p.E3.ActualSize);
			Assert.AreEqual(float2(0,60), p.E3.ActualPosition);
		}
		
		[Test]
		public void StackLayoutCompat() //https://github.com/fusetools/fuselibs/issues/1484
		{
			using (var root = new TestRootPanel())
			{
				var p = new UX.StackLayoutCompat();
				root.Children.Add(p);

				root.Layout(int2(100,1000));
				Assert.AreEqual(float2(60,30),p.I1.ActualSize);

				root.Layout(int2(200,1000));
				Assert.AreEqual(float2(160,80),p.I1.ActualSize);
			}
		}
		
		//region Private Methods
		
		private Panel GetChildForStackPanel(float4 margin, float width, float height)
		{
			var child = new Panel();
			child.Margin = margin;
			child.Width = width;
			child.Height = height;

			return child;
		}

		private Panel GetChildForStackPanelWithoutWidth(float4 margin, float height)
		{
			var child = new Panel();
			child.Margin = margin;
			child.Height = height;

			return child;
		}

		private Panel GetChildForStackPanelWithoutHeight(float4 margin, float width)
		{
			var child = new Panel();
			child.Margin = margin;
			child.Width = width;

			return child;
		}

		//endregion
	}
}
