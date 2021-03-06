using Uno;
using Uno.UX;
using Uno.Collections;

namespace Fuse
{
	public partial class Visual
	{
		public abstract void Draw(DrawContext dc);

		public bool HasVisualChildren { get { return _zOrder != null && _zOrder.Count > 0; } }

		public Visual FirstVisualChild
		{ 
			get
			{
				if (!HasVisualChildren) return null;

				return FirstChild<Visual>();
			}
		}

		public Visual GetVisualChild(int index)
		{
			if (!HasVisualChildren) return null;

			int x = 0;
			for (int i = 0; i < Children.Count; i++)
			{
				var c = Children[i] as Visual;
				if (c != null) 
				{
					if (x == index) return c;
					x++;
				}
			}
			return null;
		}

		public Visual LastVisualChild
		{ 
			get
			{
				if (!HasVisualChildren) return null;

				for (int i = Children.Count; i --> 0;)
				{
					var c = Children[i] as Visual;
					if (c != null) return c;
				}
				return null;
			}
		}

		public int ZOrderChildCount
		{
			get 
			{ 
				if (!HasVisualChildren) return 0;
				return ZOrder.Count; 
			}
		}

		public Visual GetZOrderChild(int index)
		{
			EnsureSortedZOrder();
			return ZOrder[index];
		}

		internal List<Visual> ZOrder
		{
			get
			{
				if (_zOrder == null)
					_zOrder = new List<Visual>();
					
				return _zOrder;
			}
		}
		List<Visual> _zOrder = null;

		/** Brings the given child to the front of the Z-order. 
			In UX markup, use the @BringToFront trigger action instead.
		*/
		public void BringToFront(Visual item)
		{
			if (!HasChildren)
				return;
				
			EnsureZOrder(); //to force the update of the natural zorder state
			
			int mx = item.ZOffsetNatural;
			foreach (var c in ZOrder)
			{
				if (c.ZLayer == item.ZLayer)
					mx = Math.Max(mx, c.ZOffsetNatural);
			}
			item.ZOffsetNatural = mx + 1;
			item.ZOffsetFixed = true;
			SoftInvalidateZOrder();
		}

		/** Sends the given child to the back of the Z-order. 
			In UX markup, use the @SendToBack trigger action instead.
		*/
		public void SendToBack(Visual item)
		{
			if (!HasChildren)
				return;
				
			EnsureZOrder(); //to force the update of the natural zorder state
			
			int mn = item.ZOffsetNatural;
			foreach (var c in ZOrder)
			{
				if (c.ZLayer == item.ZLayer)
					mn = Math.Min(mn, c.ZOffsetNatural);
			}
			item.ZOffsetNatural = mn - 1;
			item.ZOffsetFixed = true;
			SoftInvalidateZOrder();
		}

		int ZOrderComparator(Visual a, Visual b)
		{
			if (a.ZLayer != b.ZLayer)
				return a.ZLayer - b.ZLayer;
			//to preserve ordering through interpolation we're forced to do exact match here. This is
			//also okay, since things that need exact match will just use integer values
			if (a.ZOffset != b.ZOffset)
				return a.ZOffset > b.ZOffset ? 1 : -1;
			return a.ZOffsetNatural - b.ZOffsetNatural;
		}

		static void AssignZOrder( IList<Node> nodes )
		{
			var current = new int[]
			{
				0, // Layer.Underlay
				0, // Layer.Background
				0, // Layer.Layout
				0  // Layer.Overlay
			};

			for (int i = 0; i < nodes.Count; i++)
			{
				var visual = nodes[i] as Visual;
				if (visual == null) continue;
				
				int c = (int)visual.Layer;
				visual.ZLayer = c;
				if (!visual.ZOffsetFixed)
					visual.ZOffsetNatural = current[c]--;
			}
		}
		
		//is the zorder list sorted
		bool _sortedZOrder;
		//has the layout assigned a zorder to the nodes
		bool _nodeZOrders;
		protected int _firstNonUnderlay;
		internal void EnsureSortedZOrder()
		{
			if (_sortedZOrder && _nodeZOrders)
				return;
			
			EnsureZOrder();
			ZOrder.Sort( ZOrderComparator );
			_sortedZOrder = true;

			int firstNonUnderlay;
			for (firstNonUnderlay = 0; firstNonUnderlay < ZOrder.Count; ++firstNonUnderlay)
				if (ZOrder[firstNonUnderlay].Layer != Layer.Underlay)
					break;
			_firstNonUnderlay = firstNonUnderlay;
		}
		
		void EnsureZOrder()
		{
			if (!_nodeZOrders)
			{
				AssignZOrder(Children);
				_nodeZOrders = true;
			}
		}
		
		void OnInvalidateChildZOffset(Visual child)
		{
			SoftInvalidateZOrder();
		}
		
		internal event EventHandler ZOrderChanged;
		
		/**
			Does not invalidate the Layout assigned orders, stored in _nodeZOrders
		*/
		void SoftInvalidateZOrder(bool force = false)
		{
			OnZOrderInvalidated();
			if (!_sortedZOrder && !force)
				return;
				
			_sortedZOrder = false;
			InvalidateVisual();
			
			if (ZOrderChanged != null)
				UpdateManager.AddDeferredAction( EmitZOrderChanged );
		}

		// Needed by Element to invalidate batching
		protected virtual void OnZOrderInvalidated() {}
	
		void EmitZOrderChanged()
		{
			if (ZOrderChanged != null)
				ZOrderChanged(this, EventArgs.Empty);
		}
		
		void InvalidateZOrder()
		{
			if (!_nodeZOrders)
				return;
				
			_nodeZOrders = false;
			SoftInvalidateZOrder(true);
		}
		
	}
}
