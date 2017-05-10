using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Drawing;

namespace Fuse.Elements
{
	public interface ITreeRenderer
	{
		void RootingStarted(Element e);
		void Rooted(Element e);
		void Unrooted(Element e);
		void BackgroundChanged(Element e, Brush background);
		void TransformChanged(Element e);
		void Placed(Element e);
		void IsVisibleChanged(Element e, bool isVisible);
		void IsEnabledChanged(Element e, bool isEnabled);
		void OpacityChanged(Element e, float opacity);
		void ClipToBoundsChanged(Element e, bool clipToBounds);
		void ZOrderChanged(Element e, List<Visual> zorder);
		void HitTestModeChanged(Element e, bool enabled);
		bool Measure(Element e, LayoutParams lp, out float2 size);
	}

	internal struct TreeHandle
	{
		readonly uint _id;

		TreeHandle(uint id)
		{
			_id = id;
		}

		public static TreeHandle Null = new TreeHandle(0);

		static uint _idCounter = 1;
		public static TreeHandle New() { return new TreeHandle(_idCounter++); }
		public override bool Equals(object obj) { return obj is TreeHandle && this == (TreeHandle)obj; }
		public override int GetHashCode() { return _id.GetHashCode(); }
		public static bool operator ==(TreeHandle x, TreeHandle y) { return x._id == y._id; }
		public static bool operator !=(TreeHandle x, TreeHandle y) { return x._id != y._id; }

		public override string ToString()
		{
			return _id.ToString();
		}
	}

	public partial class Element
	{

		internal TreeHandle TreeHandle = TreeHandle.Null;

		public virtual ITreeRenderer TreeRenderer
		{
			get { return Parent	is Element ? ((Element)Parent).TreeRenderer : null; }
		}

		protected override void OnIsVisibleChanged()
		{
			base.OnIsVisibleChanged();
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.IsVisibleChanged(this, IsVisible);
			}
		}

		void NotifyTreeRendererZOrderChanged()
		{
			if (HasChildren)
				UpdateManager.AddDeferredAction(OnZOrderChanged, UpdateStage.Layout, LayoutPriority.Post);
		}

		void OnZOrderChanged()
		{
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.ZOrderChanged(this, ZOrder);
			}
		}

		bool _transformChanged = false;
		void NotifyTreeRendererTransformChanged()
		{
			if (!_transformChanged)
			{
				UpdateManager.AddDeferredAction(SetNewTransform, UpdateStage.Layout, LayoutPriority.Post);
				_transformChanged = true;
			}
		}

		void SetNewTransform()
		{
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.TransformChanged(this);
			}
			_transformChanged = false;
		}

		void NotifyTreeRendererHitTestModeChanged()
		{
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.HitTestModeChanged(this, HitTestMode != Fuse.Elements.HitTestMode.None);
			}
		}

		void NotifyTreeRedererOpacityChanged()
		{
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.OpacityChanged(this, Opacity);
			}
		}

		protected override void OnIsContextEnabledChanged()
		{
			base.OnIsContextEnabledChanged();
			if (IsRootingCompleted)
			{
				var t = TreeRenderer;
				if (t != null)
					t.IsEnabledChanged(this, IsEnabled);
			}
		}

		internal protected override void OnRootedPreChildren()
		{
			NotifyTreeRendererRootingStarted();
			base.OnRootedPreChildren();
		}

		void NotifyTreeRendererRootingStarted()
		{
			var t = TreeRenderer;
			if (t != null)
				t.RootingStarted(this);
		}

		void NotifyTreeRendererRooted()
		{
			var t = TreeRenderer;
			if (t != null)
			{
				t.Rooted(this);
				t.OpacityChanged(this, Opacity);
				t.IsVisibleChanged(this, IsVisible);
				t.IsEnabledChanged(this, IsEnabled);
				t.ClipToBoundsChanged(this, ClipToBounds);
				t.HitTestModeChanged(this, HitTestMode != Fuse.Elements.HitTestMode.None);
				if (HasChildren)
					t.ZOrderChanged(this, ZOrder);
			}
		}

		void NotifyTreeRendererUnrooted()
		{
			var t = TreeRenderer;
			if (t != null)
				TreeRenderer.Unrooted(this);
		}
	}
}
