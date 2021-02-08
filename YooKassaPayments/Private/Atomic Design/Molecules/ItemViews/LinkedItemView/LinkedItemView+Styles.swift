import UIKit

extension LinkedItemView {

    enum Styles {

        /// Style for linked switch item view.
        ///
        /// Text: secondary color
        static let linked = InternalStyle(
            name: "LinkedItemView.linked"
        ) { (item: LinkedItemView) in
            item.linkedTextView.setStyles(UITextView.Styles.linked)
        }
    }
}
