
import UIKit

class TodoCell: UITableViewCell {

	@IBOutlet var lbl_todoTitle: UILabel!
	@IBOutlet var btn_edit: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
		
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		
    }
}
