import Foundation
import MessageKit

struct Message: Hashable, Codable, Equatable {
    var id : String
    var message: String
    var createdAt: String
    var userOwned: Bool
    
    struct Request: Encodable {
        var conversationId : String
        var message : String
    }
}

//public protocol MessageType {
//
//    /// The sender of the message.
//    var sender: SenderType { get }
//
//    /// The unique identifier for the message.
//    var messageId: String { get }
//
//    /// The date the message was sent.
//    var sentDate: Date { get }
//
//    /// The kind of message and its underlying kind.
//    var kind: MessageKind { get }
//
//}

//public protocol SenderType {
//
//    /// The unique String identifier for the sender.
//    ///
//    /// Note: This value must be unique across all senders.
//    var senderId: String { get }
//
//    /// The display name of a sender.
//    var displayName: String { get }
//}

//public enum MessageKind {
//
//    /// A standard text message.
//    ///
//    /// - Note: The font used for this message will be the value of the
//    /// `messageLabelFont` property in the `MessagesCollectionViewFlowLayout` object.
//    ///
//    /// Using `MessageKind.attributedText(NSAttributedString)` doesn't require you
//    /// to set this property and results in higher performance.
//    case text(String)
//
//    /// A message with attributed text.
//    case attributedText(NSAttributedString)
//
//    /// A photo message.
//    case photo(MediaItem)
//
//    /// A video message.
//    case video(MediaItem)
//
//    /// A location message.
//    case location(LocationItem)
//
//    /// An emoji message.
//    case emoji(String)
//
//    /// An audio message.
//    case audio(AudioItem)
//
//    /// A contact message.
//    case contact(ContactItem)
//
//    /// A link preview message.
//    case linkPreview(LinkItem)
//
//    /// A custom message.
//    /// - Note: Using this case requires that you implement the following methods and handle this case:
//    ///   - MessagesDataSource: customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell
//    ///   - MessagesLayoutDelegate: customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator
//    case custom(Any?)
//
//    // MARK: - Not supported yet
//
////    case system(String)
////
////    case placeholder
//
//}
