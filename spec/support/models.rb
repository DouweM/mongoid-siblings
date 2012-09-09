class DummySuperParentDocument
  include Mongoid::Document
  
  has_many :children, class_name: "DummyReferencedChildDocument",
                      inverse_of: :super_parent
end

class DummyParentDocument
  include Mongoid::Document
  
  has_many :referenced_children,              class_name: "DummyReferencedChildDocument",
                                              inverse_of: :parent
  has_many :referenced_polymorphic_children1, class_name: "DummyReferencedChildDocument",
                                              as:         :polymorphic_parent
  has_many :referenced_polymorphic_children2, class_name: "DummyReferencedChildDocument",
                                              as:         :polymorphic_parent

  embeds_many :embedded_children,             class_name: "DummyEmbeddedChildDocument",
                                              inverse_of: :parent
  embeds_many :embedded_polymorphic_children, class_name: "DummyPolymorphicEmbeddedChildDocument",
                                              as:         :parent
end

class DummyReferencedChildDocument
  include Mongoid::Document
  include Mongoid::Siblings
  
  belongs_to :super_parent, class_name: DummySuperParentDocument.to_s,
                            inverse_of: :children
  
  belongs_to :parent, class_name: DummyParentDocument.to_s,
                      inverse_of: :referenced_children
  belongs_to :polymorphic_parent, polymorphic: true
end

class DummyEmbeddedChildDocument
  include Mongoid::Document
  include Mongoid::Siblings
  
  embedded_in :parent,  class_name: DummyParentDocument.to_s,
                        inverse_of: :embedded_children
end

class DummyPolymorphicEmbeddedChildDocument
  include Mongoid::Document
  include Mongoid::Siblings
  
  embedded_in :parent, polymorphic: true
end