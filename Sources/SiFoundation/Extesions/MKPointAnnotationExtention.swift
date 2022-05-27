import MapKit

extension MKPointAnnotation: ObservableObject
{
      public var /* prop */ wrappedTitle: String
      {
            get { self.title.default( "Неизвестное значение".localized ) }

            set { title = newValue }
      }

      public var /* prop */ wrappedSubtitle: String
      {
            get { self.subtitle.default( "Неизвестное значение".localized ) }

            set { subtitle = newValue }
      }
}
