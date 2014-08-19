require "spec_helper.rb"

describe Mongoid::Siblings do
  
  let(:parent) { DummyParentDocument.create }
  
  describe "#siblings" do
    
    context "when using a fallback scope" do
      
      let(:super_parent)      { DummySuperParentDocument.create }
      let(:parent)            { DummyParentDocument.create }
      subject                 { DummyReferencedChildDocument.create }
      let!(:main_sibling)     { DummyReferencedChildDocument.create(parent: parent, super_parent: super_parent) }
      let!(:fallback_sibling) { DummyReferencedChildDocument.create(super_parent: super_parent) }
      let!(:ultimate_sibling) { DummyReferencedChildDocument.create }
      
      context "when providing scope values" do
      
        let(:old_super_parent)  { DummySuperParentDocument.create }
        let(:old_parent)        { DummyParentDocument.create }
        
        before(:each) do
          subject.parent = parent
          subject.super_parent = super_parent
          subject.save
        end
        
        context "when providing one scope value" do

          let!(:old_main_sibling) { DummyReferencedChildDocument.create(parent: old_parent, super_parent: super_parent) }
        
          it "returns the subject's siblings" do
            subject.siblings( 
              scope:        [:parent, :super_parent], 
              scope_values: { 
                parent: old_parent 
              }
            ).to_a.should eq([old_main_sibling])
          end
        end
        
        context "when providing multiple scope values" do
        
          let!(:old_main_sibling)     { DummyReferencedChildDocument.create(parent: old_parent, super_parent: old_super_parent) }
          let!(:old_fallback_sibling) { DummyReferencedChildDocument.create(super_parent: old_super_parent) }

          context "when the main sibling value was nil" do

            it "returns the subject's siblings" do
              subject.siblings( 
                scope:        [:parent, :super_parent], 
                scope_values: { 
                  parent:       nil, 
                  super_parent: old_super_parent
                }
              ).to_a.should eq([old_fallback_sibling])
            end
          end
          
          context "when the main sibling value wasn't nil" do

            it "returns the subject's siblings" do
              subject.siblings( 
                scope:        [:parent, :super_parent], 
                scope_values: { 
                  parent:       old_parent, 
                  super_parent: old_super_parent 
                }
              ).to_a.should eq([old_main_sibling])
            end
          end
        end
      end
      
      context "when not providing scope values" do
      
        context "when the document has a main scope document" do
        
          before(:each) do
            subject.parent = parent
            subject.super_parent = super_parent
            subject.save
          end
    
          it "returns the subject's siblings" do
            subject.siblings(scope: [:parent, :super_parent]).to_a.should eq([main_sibling])
          end
        end
      
        context "when the document has a fallback scope document but not a main scope document" do
        
          before(:each) do
            subject.super_parent = super_parent
            subject.save
          end
    
          it "returns the subject's siblings" do
            subject.siblings(scope: [:parent, :super_parent]).to_a.should eq([fallback_sibling])
          end
        end
      
        context "when the document has neither a main scope document or a fallback scope document" do
    
          it "returns the subject's siblings" do
            subject.siblings(scope: [:parent, :super_parent]).to_a.should eq([ultimate_sibling])
          end
        end
      end
    end
    
    context "when using a single scope" do
      
      context "when providing a scope value" do
      
        let(:old_parent)    { DummyParentDocument.create }
        subject             { DummyReferencedChildDocument.create(parent: parent) }
        let!(:old_sibling)  { DummyReferencedChildDocument.create(parent: old_parent) }
        let!(:sibling)      { DummyReferencedChildDocument.create(parent: parent) }
        
        it "returns the subject's siblings" do
          subject.siblings(scope: :parent, scope_values: { parent: old_parent }).to_a.should eq([old_sibling])
        end
      end
      
      context "when not providing a scope value" do
      
        context "when using a referenced relation" do
        
          subject { DummyReferencedChildDocument.create }
    
          context "when using a non-polymorphic relation" do
      
            let!(:sibling) { DummyReferencedChildDocument.create(parent: parent) }
      
            before(:each) do
              subject.parent = parent
              subject.save
            end
      
            it "returns the subject's siblings" do
              subject.siblings(scope: :parent).to_a.should eq([sibling])
            end
          end

          context "when using a single polymorphic relation" do
            
            let(:super_parent)  { DummySuperParentDocument.create }
            let!(:non_sibling)  { DummyReferencedChildDocument.create }

            before(:each) do
              super_parent.polymorphic_child = subject
            end

            it "returns the subject's siblings" do
              subject.siblings(scope: :polymorphic_parent).to_a.should eq([])
            end
          end
    
          context "when using multiple polymorphic relations" do
      
            let!(:sibling) { DummyReferencedChildDocument.create.tap { |doc| parent.referenced_polymorphic_children1 << doc} }
      
            before(:each) do
              parent.referenced_polymorphic_children1 << subject
              subject.save
            end
      
            it "returns the subject's siblings" do
              subject.siblings(scope: :polymorphic_parent).to_a.should eq([sibling])
            end
          end
        end
      
        context "when using an embedded relation" do
    
          context "when using a non-polymorphic relation" do

            subject         { DummyEmbeddedChildDocument.create(parent: parent) }
            let!(:sibling)  { DummyEmbeddedChildDocument.create(parent: parent) }
      
            it "returns the subject's siblings" do
              subject.siblings(scope: :parent).to_a.should eq([sibling])
            end
          end
    
          context "when using a polymorphic relation" do
      
            subject         { DummyPolymorphicEmbeddedChildDocument.create(parent: parent) }
            let!(:sibling)  { DummyPolymorphicEmbeddedChildDocument.create(parent: parent) }
      
            it "returns the subject's siblings" do
              subject.siblings(scope: :parent).to_a.should eq([sibling])
            end
          end
        end

        context "when using a simple attribute" do
        
          subject         { DummyReferencedChildDocument.create(parent: parent) }          
          let!(:sibling)  { DummyReferencedChildDocument.create(parent: parent) }
    
          it "returns the subject's siblings" do
            subject.siblings(scope: :parent_id).to_a.should eq([sibling])
          end
        end
      end
    end
    
    context "when not using a scope" do
      
      context "when a default sibling scope is set" do
        
        before(:each) do
          DummyReferencedChildDocument.default_sibling_scope = :parent
        end
        
        after(:each) do
          DummyReferencedChildDocument.default_sibling_scope = nil
        end
        
        subject         { DummyReferencedChildDocument.create(parent: parent) }
        let!(:sibling)  { DummyReferencedChildDocument.create(parent: parent) }
  
        it "returns the subject's siblings through the default sibling scope" do
          subject.siblings.to_a.should eq([sibling])
        end
      end
      
      context "when no default sibling scope is set" do
      
        subject         { DummyReferencedChildDocument.create }
        let!(:sibling)  { DummyReferencedChildDocument.create }
      
        it "returns all other documents of the subject's type" do
          subject.siblings.to_a.should eq([sibling])
        end
      end
    end
  end
  
  describe "#siblings_and_self" do
      
    subject         { DummyReferencedChildDocument.create(parent: parent) }
    let!(:sibling)  { DummyReferencedChildDocument.create(parent: parent) }

    it "returns the subject's siblings and the subject itself" do
      subject.siblings_and_self(scope: :parent).to_a.sort.should eq([subject, sibling].sort)
    end
  end

  describe "#sibling_of?" do
    
    context "when using a fallback scope" do
      
      let(:super_parent)      { DummySuperParentDocument.create }
      let(:parent)            { DummyParentDocument.create }
      subject                 { DummyReferencedChildDocument.create }
      let!(:main_sibling)     { DummyReferencedChildDocument.create(parent: parent, super_parent: super_parent) }
      let!(:fallback_sibling) { DummyReferencedChildDocument.create(super_parent: super_parent) }
      let!(:ultimate_sibling) { DummyReferencedChildDocument.create }
      
      context "when providing scope values" do
      
        let(:old_super_parent)  { DummySuperParentDocument.create }
        let(:old_parent)        { DummyParentDocument.create }
        
        before(:each) do
          subject.parent = parent
          subject.super_parent = super_parent
          subject.save
        end
        
        context "when providing one scope value" do

          let!(:old_main_sibling) { DummyReferencedChildDocument.create(parent: old_parent, super_parent: super_parent) }
        
          context "when called with a sibling" do
    
            it "returns true" do
              subject.should be_sibling_of(
                old_main_sibling, 
                scope:        [:parent, :super_parent], 
                scope_values: {
                  parent: old_parent
                }
              )
            end
          end
        
          context "when not called with a sibling" do
    
            it "returns false" do
              subject.should_not be_sibling_of(
                main_sibling,      
                scope:        [:parent, :super_parent], 
                scope_values: {
                  parent: old_parent
                }
              )
              subject.should_not be_sibling_of(
                fallback_sibling,  
                scope:        [:parent, :super_parent], 
                scope_values: {
                  parent: old_parent
                }
              )
              subject.should_not be_sibling_of(
                ultimate_sibling,  
                scope:        [:parent, :super_parent], 
                scope_values: {
                  parent: old_parent
                }
              )
            end
          end
        end
        
        context "when providing multiple scope values" do
        
          let!(:old_main_sibling)     { DummyReferencedChildDocument.create(parent: old_parent, super_parent: old_super_parent) }
          let!(:old_fallback_sibling) { DummyReferencedChildDocument.create(super_parent: old_super_parent) }
          
          context "when the main sibling value was nil" do

            context "when called with a sibling" do
    
              it "returns true" do
                subject.should be_sibling_of(
                  old_fallback_sibling, 
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       nil, 
                    super_parent: old_super_parent
                  }
                )
              end
            end
        
            context "when not called with a sibling" do
    
              it "returns false" do
                subject.should_not be_sibling_of(
                  old_main_sibling,  
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       nil, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  main_sibling,      
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       nil, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  fallback_sibling,  
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       nil, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  ultimate_sibling,  
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       nil, 
                    super_parent: old_super_parent
                  }
                )
              end
            end
          end
          
          context "when the main sibling value was not nil" do

            context "when called with a sibling" do
    
              it "returns true" do
                subject.should be_sibling_of(
                  old_main_sibling, 
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       old_parent, 
                    super_parent: old_super_parent
                  }
                )
              end
            end
        
            context "when not called with a sibling" do
    
              it "returns false" do
                subject.should_not be_sibling_of(
                  old_fallback_sibling,  
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       old_parent, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  main_sibling,          
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       old_parent, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  fallback_sibling,      
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       old_parent, 
                    super_parent: old_super_parent
                  }
                )
                subject.should_not be_sibling_of(
                  ultimate_sibling,      
                  scope:        [:parent, :super_parent], 
                  scope_values: {
                    parent:       old_parent, 
                    super_parent: old_super_parent
                  }
                )
              end
            end
          end
        end
      end
      
      context "when providing other scope values" do
      
        let(:old_super_parent)  { DummySuperParentDocument.create }
        let(:old_parent)        { DummyParentDocument.create }
        
        before(:each) do
          subject.parent = parent
          subject.super_parent = super_parent
          subject.save
        end
        
        context "when providing one other scope value" do

          let!(:old_main_sibling) { DummyReferencedChildDocument.create(parent: old_parent, super_parent: super_parent) }
        
          context "when called with a sibling" do
    
            it "returns true" do
              subject.should be_sibling_of(
                old_main_sibling, 
                scope:              [:parent, :super_parent], 
                other_scope_values: {
                  parent: parent
                }
              )
            end
          end
        end
        
        context "when providing multiple other scope values" do
        
          let!(:old_main_sibling)     { DummyReferencedChildDocument.create(parent: old_parent, super_parent: old_super_parent) }
          let!(:old_fallback_sibling) { DummyReferencedChildDocument.create(super_parent: old_super_parent) }
          
          context "when the other main sibling value was nil" do
            
            before(:each) do
              subject.parent = nil
              subject.save
            end

            context "when called with a sibling" do
    
              it "returns true" do
                subject.should be_sibling_of(
                  old_fallback_sibling, 
                  scope:              [:parent, :super_parent], 
                  other_scope_values: {
                    parent:       nil, 
                    super_parent: super_parent
                  }
                )
              end
            end
          end
          
          context "when the other main sibling value was not nil" do

            context "when called with a sibling" do
    
              it "returns true" do
                subject.should be_sibling_of(
                  old_main_sibling, 
                  scope:              [:parent, :super_parent], 
                  other_scope_values: {
                    parent:       parent, 
                    super_parent: super_parent
                  }
                )
              end
            end
          end
        end
      end
      
      context "when not providing scope values" do

        context "when the document has a main scope document" do
        
          before(:each) do
            subject.parent = parent
            subject.super_parent = super_parent
            subject.save
          end
        
          context "when called with a sibling" do
    
            it "returns true" do
              subject.should be_sibling_of(main_sibling, scope: [:parent, :super_parent])
            end
          end
        
          context "when not called with a sibling" do
    
            it "returns false" do
              subject.should_not be_sibling_of(fallback_sibling, scope: [:parent, :super_parent])
              subject.should_not be_sibling_of(ultimate_sibling, scope: [:parent, :super_parent])
            end
          end
        end
      
        context "when the document has a fallback scope document but not a main scope document" do
        
          before(:each) do
            subject.super_parent = super_parent
            subject.save
          end
        
          context "when called with a sibling" do
    
            it "returns true" do
              subject.should be_sibling_of(fallback_sibling, scope: [:parent, :super_parent])
            end
          end
        
          context "when not called with a sibling" do
    
            it "returns false" do
              subject.should_not be_sibling_of(main_sibling,      scope: [:parent, :super_parent])
              subject.should_not be_sibling_of(ultimate_sibling,  scope: [:parent, :super_parent])
            end
          end
        end
      
        context "when the document has neither a main scope document or a fallback scope document" do
        
          context "when called with a sibling" do
    
            it "returns true" do
              subject.should be_sibling_of(ultimate_sibling, scope: [:parent, :super_parent])
            end
          end
        
          context "when not called with a sibling" do
    
            it "returns false" do
              subject.should_not be_sibling_of(main_sibling,      scope: [:parent, :super_parent])
              subject.should_not be_sibling_of(fallback_sibling,  scope: [:parent, :super_parent])
            end
          end
        end
      end
    end
    
    context "when using a scope" do
      
      context "when called with a sibling" do
        
        subject       { DummyReferencedChildDocument.create(parent: parent) }
        let(:sibling) { DummyReferencedChildDocument.create(parent: parent) }
      
        it "returns true" do
          subject.should be_sibling_of(sibling, scope: :parent)
        end
      end
      
      context "when not called with a sibling" do
        
        subject             { DummyReferencedChildDocument.create(parent: parent) }
        let(:other_parent)  { DummyParentDocument.create }
        let(:non_sibling)   { DummyReferencedChildDocument.create(parent: other_parent) }
      
        it "returns false" do
          subject.should_not be_sibling_of(non_sibling, scope: :parent)
        end
      end
    end
    
    context "when not using a scope" do
      
      context "when called with a sibling" do
        
        subject       { DummyReferencedChildDocument.create }
        let(:sibling) { DummyReferencedChildDocument.create }
      
        it "returns true" do
          subject.should be_sibling_of(sibling)
        end
      end
      
      context "when not called with a sibling" do
        
        subject { DummyReferencedChildDocument.create }
      
        it "returns false" do
          subject.should_not be_sibling_of(parent)
        end
      end
    end
  end

  describe "#become_sibling_of!" do

    context "when called with a sibling" do
      
      let(:parent)    { DummyParentDocument.create }
      subject         { DummyReferencedChildDocument.create(parent: parent) }
      let!(:sibling)  { DummyReferencedChildDocument.create(parent: parent) }

      it "returns true" do
        subject.become_sibling_of!(sibling, scope: :parent).should be_true
      end
    end

    context "when not called with a sibling" do

      context "when called with an object that can never be a sibling" do

        let(:parent)        { DummyParentDocument.create }
        subject             { DummyReferencedChildDocument.create(parent: parent) }
        let!(:non_sibling)  { DummyParentDocument.create }

        it "returns false" do
          subject.become_sibling_of!(non_sibling, scope: :parent).should be_false
        end
      end

      context "when called with an object that could be a sibling" do

        let(:super_parent)  { DummySuperParentDocument.create }
        let(:parent)        { DummyParentDocument.create }
        subject             { DummyReferencedChildDocument.create }
        let!(:new_sibling)  { DummyReferencedChildDocument.create(parent_id: parent.id, super_parent: super_parent) }

        let(:options)       { [new_sibling, scope: [:parent_id, :super_parent]] }

        it "copies the scope values from the object to the subject" do
          subject.become_sibling_of!(*options)

          subject.parent_id.should eq(new_sibling.parent_id)
          subject.super_parent.should eq(new_sibling.super_parent)
        end

        it "saves the subject" do
          subject.should_receive(:save!)

          subject.become_sibling_of!(*options)
        end

        it "returns true" do
          subject.become_sibling_of!(*options).should be_true
        end

        it "makes the subject a sibling of the object" do
          subject.become_sibling_of!(*options).should be_true

          subject.should be_sibling_of(*options)
        end
      end
    end
  end
end