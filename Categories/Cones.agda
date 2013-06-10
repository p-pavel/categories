{-# OPTIONS --universe-polymorphism #-}
module Categories.Cones where

open import Level

open import Categories.Support.PropositionalEquality

open import Categories.Operations
open import Categories.Category
open import Categories.Functor hiding (_≡_; equiv; id; assoc; identityˡ; identityʳ; ∘-resp-≡)
open import Categories.Cone
open import Categories.Square

record ConeMorphism {o a} {o′ a′} {C : Category o a} {J : Category o′ a′} {F : Functor J C} (c₁ c₂ : Cone F) : Set (a ⊔ o′ ⊔ a′) where
  module c₁ = Cone c₁
  module c₂ = Cone c₂
  module C = Category C
  module J = Category J
  open C
  field
    f : C [ c₁.N , c₂.N ]
    .commute : ∀ {X} → c₁.ψ X ≡ c₂.ψ X ∘ f

Conesᵉ : ∀ {o a} {o′ a′} {C : Category o a} {J : Category o′ a′} (F : Functor J C) → EasyCategory (o ⊔ a ⊔ o′ ⊔ a′) (a ⊔ o′ ⊔ a′) a
Conesᵉ {C = C} F = record 
  { Obj = Obj′
  ; _⇒_ = Hom′
  ; _≡_ = _≡′_
  ; compose = _∘′_
  ; id = record { f = id; commute = Equiv.sym identityʳ }
  ; assoc = assoc
  ; identityˡ = identityˡ
  ; identityʳ = identityʳ
  ; promote = promote′
  ; REFL = Equiv.refl
  }
  where
  open Category C
  open GlueSquares C
  open Cone
  open ConeMorphism
  open Functor F

  infixr 9 _∘′_
  infix  4 _≡′_

  Obj′ = Cone F

  Hom′ : Obj′ → Obj′ → Set _
  Hom′ = ConeMorphism

  _≡′_ : ∀ {A B} → Hom′ A B → Hom′ A B → Set _
  F ≡′ G = f F ≡ f G

  promote′ : ∀ {A B} (f g : ConeMorphism A B) → f ≡′ g → f ≣ g
  promote′ {c₁} {c₂} f g f≡g = lemma f≡g
    where
    module f = ConeMorphism f
    lemma : ∀ {f′} (eq : f.f ≣ f′) → f ≣ record { f = f′; commute = ≣-subst (λ f″ → ∀ {X} → f.c₁.ψ X ≡ f.c₂.ψ X ∘ f″) eq f.commute }
    lemma ≣-refl = ≣-refl

  _∘′_ : ∀ {A B C} → Hom′ B C → Hom′ A B → Hom′ A C
  _∘′_ {A} {B} {C} F G = record 
    { f = f F ∘ f G
    ; commute = commute′
    }
    where
    .commute′ : ∀ {X} → ψ A X ≡ ψ C X ∘ (f F ∘ f G)
    commute′ {X} = 
        begin
          ψ A X
        ↓⟨ ConeMorphism.commute G ⟩
          ψ B X ∘ f G
        ↓⟨ pushˡ (ConeMorphism.commute F) ⟩
          ψ C X ∘ (f F ∘ f G)
        ∎
      where
      open HomReasoning

Cones : ∀ {o a} {o′ a′} {C : Category o a} {J : Category o′ a′} (F : Functor J C) → Category (o ⊔ a ⊔ o′ ⊔ a′) (a ⊔ o′ ⊔ a′)
Cones F = EASY Conesᵉ F

-- Equality of cone morphisms is equality of the underlying arrows in the
-- base category, but the same is not (directly) true of the heterogeneous
-- equality.  These functions make the equivalence manifest.

module Heteroconic {o a} {o′ a′} {C : Category o a} {J : Category o′ a′} (F : Functor J C) where
  open Heterogeneous C
  module ▵ = Heterogeneous (Cones F)
  open ▵ public using () renaming (_∼_ to _▵̃_)
  open ConeMorphism using () renaming (f to ⌞_⌝)

  demote-∼ : ∀ {K L K′ L′} {f : ConeMorphism K L} {g : ConeMorphism K′ L′}
           → f ▵̃ g → ⌞ f ⌝ ∼ ⌞ g ⌝
  demote-∼ (≡⇒∼ y) = Heterogeneous.≡⇒∼ (≣-cong ⌞_⌝ y)

  -- XXX probably need another argument or something to nail things down
  -- promote-∼ : ∀ {K L K′ L′} {f : ConeMorphism {C = C} K L} {g : ConeMorphism {C = C} K′ L′}
  --           → ⌞ f ⌝ ∼ ⌞ g ⌝ → f ▵̃ g
  -- promote-∼ h = {!h!}

-- The category of cones comes with an equivalence of objects, which can be
-- used to float morphisms from one to another.  Really it should have a
-- setoid of objects, but we're not equipped for that.

module Float {o a} {o′ a′} {C : Category o a} {J : Category o′ a′} (F : Functor J C) where

  module H = Heterogeneous C
  open H hiding (float₂; floatˡ; floatʳ; floatˡ-resp-trans; float₂-breakdown-lr; float₂-breakdown-rl)

  private
    lemma₁ : ∀ (A B : Cone F) {f₁ f₂ : C [ Cone.N A , Cone.N B ]} (f₁≣f₂ : f₁ ≣ f₂) .(pf₁ : ∀ {X} → C [ Cone.ψ A X ≡ C [ Cone.ψ B X ∘ f₁ ] ]) .(pf₂ : ∀ {X} → C [ Cone.ψ A X ≡ C [ Cone.ψ B X ∘ f₂ ] ]) → _≣_ {A = ConeMorphism A B} record { f = f₁ ; commute = pf₁ } record { f = f₂ ; commute = pf₂ }
    lemma₁ A B ≣-refl = λ ._ ._ → ≣-refl

  morphism-determines-cone-morphism-≣ : ∀ {A B} {m m′ : Cones F [ A , B ]} → ConeMorphism.f m ≣ ConeMorphism.f m′ → m ≣ m′
  morphism-determines-cone-morphism-≣ {A} {B} {m} {m′} pf = lemma₁ A B pf (ConeMorphism.commute m) (ConeMorphism.commute m′)

  float₂ : ∀ {A A′ B B′} → F [ A ≜ A′ ] → F [ B ≜ B′ ] → Cones F [ A , B ] → Cones F [ A′ , B′ ]
  float₂ A≜A′ B≜B′ κ = record 
    { f = H.float₂ (N-≣ A≜A′) (N-≣ B≜B′) f
    ; commute = λ {j} → ∼⇒≡ (trans (sym (ψ-≡ A≜A′ j)) (trans (≡⇒∼ commute) (∘-resp-∼ (ψ-≡ B≜B′ j) (float₂-resp-∼ (N-≣ A≜A′) (N-≣ B≜B′)))))
    }
    where
    open ConeMorphism κ
    open ConeOver._≜_ F

  floatˡ : ∀ {A B B′} → F [ B ≜ B′ ] → Cones F [ A , B ] → Cones F [ A , B′ ]
  floatˡ {A = A} B≜B′ κ = record 
    { f = H.floatˡ N-≣ f
    ; commute = λ {j} → C.Equiv.trans commute (∼⇒≡ (∘-resp-∼ (ψ-≡ j) (floatˡ-resp-∼ N-≣)))
    }
    where
    module A = Cone A
    open ConeMorphism κ
    open ConeOver._≜_ F B≜B′

  floatˡ-resp-refl : ∀ {A B} (κ : Cones F [ A , B ]) → floatˡ {A} {B} (ConeOver.≜-refl F) κ ≣ κ
  floatˡ-resp-refl f = ≣-refl

  floatˡ-resp-trans : ∀ {A B B′ B″} (B≜B′ : F [ B ≜ B′ ]) (B′≜B″ : F [ B′ ≜ B″ ]) (κ : Cones F [ A , B ]) → floatˡ {A} {B} {B″} (ConeOver.≜-trans F B≜B′ B′≜B″) κ ≣ floatˡ {A} {B′} {B″} B′≜B″ (floatˡ {A} {B} {B′} B≜B′ κ)
  floatˡ-resp-trans {A} {B} {B′} {B″} B≜B′ B′≜B″ κ = morphism-determines-cone-morphism-≣ {A} {B″} {floatˡ {A} {B} {B″} (ConeOver.≜-trans F B≜B′ B′≜B″) κ} {floatˡ {A} {B′} {B″} B′≜B″ (floatˡ {A} {B} {B′} B≜B′ κ)} (H.floatˡ-resp-trans (N-≣ B≜B′) (N-≣ B′≜B″) f)
    where
    module A = Cone A
    open ConeOver._≜_ F
    open ConeMorphism κ

  floatʳ : ∀ {A A′ B} → F [ A ≜ A′ ] → Cones F [ A , B ] → Cones F [ A′ , B ]
  floatʳ {B = B} A≜A′ κ = record 
    { f = ≣-subst (λ X → C [ X , B.N ]) N-≣ f
    ; commute = λ {j} → ∼⇒≡ (trans (sym (ψ-≡ j)) (trans (≡⇒∼ commute) (∘-resp-∼ʳ (floatʳ-resp-∼ N-≣))))
    }
    where
    module B = Cone B
    open ConeMorphism κ
    open ConeOver._≜_ F A≜A′

  float₂-breakdown-lr : ∀ {A A′ B B′ : Cone F} (A≜A′ : F [ A ≜ A′ ]) (B≜B′ : F [ B ≜ B′ ]) (κ : Cones F [ A , B ]) → float₂ A≜A′ B≜B′ κ ≣ floatˡ B≜B′ (floatʳ A≜A′ κ)
  float₂-breakdown-lr {A′ = A′} {B′ = B′} A≜A′ B≜B′ κ = morphism-determines-cone-morphism-≣ {A = A′} {B′} {float₂ A≜A′ B≜B′ κ} {floatˡ B≜B′ (floatʳ A≜A′ κ)} (H.float₂-breakdown-lr (N-≣ A≜A′) (N-≣ B≜B′) (ConeMorphism.f κ))
    where open ConeOver._≜_ F

  float₂-breakdown-rl : ∀ {A A′ B B′ : Cone F} (A≜A′ : F [ A ≜ A′ ]) (B≜B′ : F [ B ≜ B′ ]) (κ : Cones F [ A , B ]) → float₂ A≜A′ B≜B′ κ ≣ floatʳ A≜A′ (floatˡ B≜B′ κ)
  float₂-breakdown-rl {A′ = A′} {B′ = B′} A≜A′ B≜B′ κ = morphism-determines-cone-morphism-≣ {A = A′} {B′} {float₂ A≜A′ B≜B′ κ} {floatʳ A≜A′ (floatˡ B≜B′ κ)} (H.float₂-breakdown-rl (N-≣ A≜A′) (N-≣ B≜B′) (ConeMorphism.f κ))
    where open ConeOver._≜_ F
