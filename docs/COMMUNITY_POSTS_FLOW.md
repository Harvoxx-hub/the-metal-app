# Community posts: how loading and display work

## Single source of truth

- **`CommunityDetailViewModel.state.posts`** is the only list. Everything on screen comes from this.

## Loading

1. User opens a community → `CommunityDetailView(communityId)` is pushed.
2. The view watches **`communityDetailViewModelProvider(communityId)`**.
3. The provider (on first use) creates the viewmodel and calls **`loadCommunityDetails(communityId)`**.
4. That calls the API and sets **`state.posts = result.data!.recentPosts`**.
5. The viewmodel notifies listeners → UI rebuilds with the new list.

## Display

1. **CommunityDetailView** gets `detailState` from the same provider.
2. It passes **`detailState.posts`** into **CommunityPostsTab** (redundantly as `initialPosts` — the tab also watches the provider).
3. **CommunityPostsTab** watches **`communityDetailViewModelProvider(communityId)`** and uses **`detailState.posts`** for the list.
4. **ListView.builder** is built with `itemCount: posts.length` and `itemBuilder` that builds a **ThoughtCard** per post.

So: **list on screen = `state.posts`**. No separate “list view state”; the list is the viewmodel state.

## When you remove a post

1. **ThoughtCard** (with `communityId`) calls **`communityVm.removePost(thoughtId)`**.
2. Viewmodel does: `state = state.copyWith(posts: updatedPosts)` (list without that id).
3. Provider notifies → **CommunityPostsTab** rebuilds.
4. **ListView.builder** gets the new `posts` (one fewer item) → that item disappears from the UI.

So: **if it’s removed from state, it’s removed from the list**. No scroll or “restart” needed; the UI is driven by `state.posts`.

## When you add a post

1. **CreateThoughtScreen** adds an optimistic **ThoughtDto** with **`communityVm.addPost(optimisticThought)`**.
2. Viewmodel does: `state = state.copyWith(posts: [post, ...state.posts])`.
3. Provider notifies → tab rebuilds → new post appears at top.
4. After API success, **`replacePost(optimisticId, realThought)`** swaps the placeholder for the server thought.

Same idea: **list on screen = `state.posts`**; add/remove/replace in state and the list updates.
