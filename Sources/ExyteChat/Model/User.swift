//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import UIKit

public struct User: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let avatarURL: Avatar?
    public let isCurrentUser: Bool

    public init(id: String, name: String, avatarURL: Avatar?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
		
	public enum Avatar: Codable, Hashable {
		case remote(URL)
		case image(UIImage)
		
		// MARK: - Codable
		
		private enum CodingKeys: String, CodingKey {
			case remote, image
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			if let url = try container.decodeIfPresent(URL.self, forKey: .remote) {
				self = .remote(url)
			} else if let imageData = try container.decodeIfPresent(Data.self, forKey: .image),
					  let image = UIImage(data: imageData) {
				self = .image(image)
			} else {
				throw DecodingError.dataCorruptedError(forKey: .image,
													   in: container,
													   debugDescription: "Invalid AvatarImage")
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			switch self {
			case .remote(let url):
				try container.encode(url, forKey: .remote)
			case .image(let image):
				guard let imageData = image.jpegData(compressionQuality: 1.0) else {
					throw EncodingError.invalidValue(image,
													 EncodingError.Context(codingPath: [],
																		   debugDescription: "UIImage could not be encoded"))
				}
				try container.encode(imageData, forKey: .image)
			}
		}
		
		// MARK: - Hashable
		
		public func hash(into hasher: inout Hasher) {
			switch self {
			case .remote(let url):
				hasher.combine(url)
			case .image(let image):
				if let imageData = image.pngData() {
					hasher.combine(imageData)
				}
			}
		}
	}

}
